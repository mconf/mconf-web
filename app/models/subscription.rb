# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Subscription < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :plan, foreign_key: 'plan_token', primary_key: "ops_token"
  belongs_to :user

  has_many :invoices

  validates :user_id, :presence => true, :uniqueness => true
  validates :plan_token, :presence => true

  validates :pay_day, :presence => true
  validates :cpf_cnpj, :presence => true
  validates :address, :presence => true
  validates :number, :presence => true
  validates :zipcode, :presence => true
  validates :city, :presence => true
  validates :province, :presence => true
  validates :district, :presence => true

  before_create :create_customer_and_sub
  after_create :subscription_created_notification
  before_update :update_sub
  before_destroy :destroy_sub
  before_destroy :subscription_destroyed_notification

  scope :not_on_trial, -> {
    joins(:user).where("trial_expires_at <= ?", DateTime.now)
  }

  def setup(user, ops)
    free_months = Rails.application.config.trial_months
    pay_day = Rails.application.config.due_day

    self.user_id = user.id
    # Will create it on IUGU for now
    self.plan_token = Plan.find_by(ops_type: ops).ops_token
    # Will create invoice for the 10th of the month after the trial expires (Mconf is post payed)
    self.pay_day = (Date.today + free_months.months + 1.month).strftime("%Y-%m-#{pay_day}")
    # This will define when to start charging the user
    self.user.set_expire_date!
  end

  def create_customer_and_sub
    if self.plan.ops_type == Plan::OPS_TYPES[:iugu]
      unless self.subscription_token.present?
        self.customer_token =
          Mconf::Iugu.create_customer(
            self.user.email,
            self.user.full_name,
            self.cpf_cnpj,
            self.address,
            self.additional_address_info,
            self.number,
            self.zipcode,
            self.city,
            self.province,
            self.district,
            self.country
          )

        if self.customer_token.blank?
          logger.error I18n.t('.subscription.errors.no_token')
          errors.add(:ops_error, I18n.t('.subscription.errors.no_token'))
          raise ActiveRecord::Rollback
        elsif self.customer_token["cpf_cnpj"].present? && self.customer_token["zip_code"].present?
          errors.add(:cpf_cnpj, :invalid)
          errors.add(:zipcode, :invalid)
          raise ActiveRecord::Rollback
        elsif self.customer_token["cpf_cnpj"].present?
          errors.add(:cpf_cnpj, :invalid)
          raise ActiveRecord::Rollback
        elsif self.customer_token["zip_code"].present?
          errors.add(:zipcode, :invalid)
          raise ActiveRecord::Rollback
        end

        # Here we are calling the creation of the subscription:
        self.create_sub
      end
    else
      logger.error I18n.t('.subscription.errors.ops_type_customer')
      errors.add(:ops_error, I18n.t('.subscription.errors.ops_type_customer'))
      raise ActiveRecord::Rollback
    end
  end

  def create_sub
    if self.plan.ops_type == Plan::OPS_TYPES[:iugu]
      self.subscription_token =
        Mconf::Iugu.create_subscription(
          self.plan.identifier,
          self.customer_token,
          self.pay_day
        )

      if self.subscription_token.blank?
        logger.error I18n.t('.subscription.errors.no_token')
        errors.add(:ops_error, I18n.t('.subscription.errors.no_token'))
        raise ActiveRecord::Rollback
      end

      self.user.bigbluebutton_room.update_attributes(max_participants: nil)

    else
      logger.error I18n.t('.subscription.errors.ops_type_create_subscription')
      errors.add(:ops_error, I18n.t('.subscription.errors.ops_type_create_subscription'))
      raise ActiveRecord::Rollback
    end
  end

  # This update function does not cover changes in user full_name or email for now
  def update_sub
    if self.plan.ops_type == Plan::OPS_TYPES[:iugu]
      updated =
        Mconf::Iugu.update_customer(
          self.customer_token,
          self.cpf_cnpj,
          self.address,
          self.additional_address_info,
          self.number,
          self.zipcode,
          self.city,
          self.province,
          self.district
        )

      if updated == false
        logger.error I18n.t('.subscription.errors.update')
        raise ActiveRecord::Rollback
      elsif updated.is_a?(Hash)
        if updated["cpf_cnpj"].present? && updated["zip_code"].present?
          errors.add(:cpf_cnpj, :invalid)
          errors.add(:zipcode, :invalid)
          raise ActiveRecord::Rollback
        elsif updated["cpf_cnpj"].present?
          errors.add(:cpf_cnpj, :invalid)
          raise ActiveRecord::Rollback
        elsif updated["zip_code"].present?
          errors.add(:zipcode, :invalid)
          raise ActiveRecord::Rollback
        end
      end

    else
      logger.error I18n.t('.subscription.errors.ops_type_update_customer')
      errors.add(:ops_error, I18n.t('.subscription.errors.ops_type_update_customer'))
      raise ActiveRecord::Rollback
    end
  end

  def self.import_ops_sub
    subscriptions = Mconf::Iugu.fetch_all_subscriptions
    if subscriptions.present?
      subscriptions.each do |subs|
        cust = Mconf::Iugu.find_customer_by_id(subs.customer_id)
        user = User.find_by(email: cust.email)
        plan = Plan.find_by(identifier: subs.plan_identifier)

        if user.present? && plan.present?
          params = {
            plan_token: plan.ops_token,
            user_id: user.id,
            subscription_token: subs.id,
            customer_token: cust.id,
            pay_day: subs.expires_at,
            cpf_cnpj: cust.cpf_cnpj,
            address: cust.street,
            additional_address_info: cust.complement,
            number: cust.number,
            zipcode: cust.zip_code,
            city: cust.city,
            province: cust.state,
            district: cust.district,
            country: (cust.custom_variables.find{ |x| x['name'] == "Country" }.try(:[],'value')),
            integrator: false
          }

          if Subscription.find_by(subscription_token: (params[:subscription_token])).present?
            logger.info I18n.t('.subscription.info')
          else
            Subscription.create(params)
            trial_expiraion = (subs.created_at.to_datetime)+(Rails.application.config.trial_months.months)
            user.update_attributes(trial_expires_at: trial_expiraion)
            user.bigbluebutton_room.update_attributes(max_participants: nil)
          end
        else
          # Should we create a new user based on the subscription?
          # If it's the missing plan, must import plans and then try again
          logger.error I18n.t('.subscription.errors.match')
        end
      end
    end
  end

  # Destroy the customer on OPS, if there's a customer token set in the model.
  def destroy_sub
    if self.invoices.last.present?
      self.invoices.last.generate_consumed_days("destroy")
    end
    if self.plan.ops_type == Plan::OPS_TYPES[:iugu]
      subscription = Mconf::Iugu.destroy_subscription(self.subscription_token)

      if subscription == false
        logger.error I18n.t('.subscription.errors.delete_subscription')
        errors.add(:ops_error, I18n.t('.subscription.errors.delete'))
        raise ActiveRecord::Rollback
      end

      customer = Mconf::Iugu.destroy_customer(self.customer_token)

      if customer == false
        logger.error I18n.t('.subscription.errors.delete_customer')     
        errors.add(:ops_error, I18n.t('.subscription.errors.delete_customer'))
        raise ActiveRecord::Rollback
      end

      self.user.bigbluebutton_room.update_attributes(max_participants: 2)

    else
      logger.error I18n.t('.subscription.errors.ops_type_destroy_subscription')
    end
  end

  def subscription_created_notification
    subscription_owner = User.find_by(id: self.user_id)
    create_activity 'created', owner: self, recipient: subscription_owner, notified: false
  end

  def subscription_destroyed_notification
    subscription_owner = User.find_by(id: self.user_id)
    create_activity 'destroyed', owner: self, recipient: subscription_owner, notified: false
  end

end
