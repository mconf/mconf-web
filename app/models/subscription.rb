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

  def create_customer_and_sub
    if self.plan.ops_type == "IUGU"
      unless self.subscription_token.present?
        self.customer_token = Mconf::Iugu.create_customer(
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
                                            self.country)

        if self.customer_token == nil
          logger.error "No Token returned from IUGU, aborting"
          errors.add(:ops_error, "No Token returned from IUGU, aborting")
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
      else
        # If this is an imported subscription we must se the max_participants
        self.user.bigbluebutton_room.update_attributes(max_participants: nil)
      end
    else
      logger.error "Bad ops_type, can't create customer"
      errors.add(:ops_error, "Bad ops_type, can't create customer")
      raise ActiveRecord::Rollback
    end
  end

  def create_sub
    if self.plan.ops_type == "IUGU"
      self.subscription_token = Mconf::Iugu.create_subscription(
                                              self.plan.identifier,
                                              self.customer_token,
                                              self.pay_day)

      if self.subscription_token == nil
        logger.error "No Token returned from IUGU, aborting"
        errors.add(:ops_error, "No Token returned from IUGU, aborting")
        raise ActiveRecord::Rollback
      end

      self.user.bigbluebutton_room.update_attributes(max_participants: nil)

    else
      logger.error "Bad ops_type, can't create subscription"
      errors.add(:ops_error, "Bad ops_type, can't create subscription")
      raise ActiveRecord::Rollback
    end
  end

  # This update function does not cover changes in user full_name or email for now
  def update_sub
    if self.plan.ops_type == "IUGU"
      updated = Mconf::Iugu.update_customer(
                              self.customer_token,
                              self.cpf_cnpj,
                              self.address,
                              self.additional_address_info,
                              self.number,
                              self.zipcode,
                              self.city,
                              self.province,
                              self.district)

      if updated == false
        logger.error "Could not update IUGU, aborting"
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
      logger.error "Bad ops_type, can't update customer"
      errors.add(:ops_error, "Bad ops_type, can't update customer")
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

          if Subscription.find_by_subscription_token(params[:subscription_token]).present?
            puts("Subscription already imported")
          else
            Subscription.create(params)
            trial_expitaion = (subs.created_at.to_datetime)+(Rails.application.config.trial_months.months)
            user.update_attributes(trial_expires_at: trial_expitaion)
          end
        else
          # Should we create a new user based on the subscription?
          # If it's the missing plan, must import plans and then try again
          puts "Failed to match this subscription to a user or plan"
        end
      end
    end
  end

  # Destroy the customer on OPS, if there's a customer token set in the model.
  def destroy_sub
    if self.invoices.last.present?
      self.invoices.last.generate_consumed_days("destroy")
    end
    if self.plan.ops_type == "IUGU"
      subscription = Mconf::Iugu.destroy_subscription(self.subscription_token)

      if subscription == false
        logger.error "Could not delete subscription from OPS, aborting"
        errors.add(:ops_error, "Could not delete subscription from OPS, aborting")
        raise ActiveRecord::Rollback
      end

      customer = Mconf::Iugu.destroy_customer(self.customer_token)

      if customer == false
        logger.error "Could not delete customer from OPS, aborting"
        errors.add(:ops_error, "Could not delete customer from OPS, aborting")
        raise ActiveRecord::Rollback
      end

      self.user.bigbluebutton_room.update_attributes(max_participants: 2)

    else
      logger.error "Bad ops_type, can't destroy subscription"
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
