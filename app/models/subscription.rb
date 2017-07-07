# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Subscription < ActiveRecord::Base
  belongs_to :plan
  belongs_to :user

  validates :user_id, :presence => true, :uniqueness => true
  validates :plan_id, :presence => true

  validates :pay_day, :presence => true
  validates :cpf_cnpj, :presence => true
  validates :address, :presence => true
  validates :number, :presence => true
  validates :zipcode, :presence => true
  validates :city, :presence => true
  validates :province, :presence => true
  validates :district, :presence => true
  validates :country, :presence => true

  attr_accessor :payment_token

  before_create :create_customer_and_sub
  before_destroy :destroy_sub

  def create_customer_and_sub
    if self.plan.ops_type == "IUGU"
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
        errors.add(:attr, "No Token returned from IUGU, aborting")
        raise ActiveRecord::Rollback
      end

      self.create_sub
    else
      logger.error "Bad ops_type, can't create customer"
      errors.add(:attr, "Bad ops_type, can't create customer")
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
        errors.add(:attr, "No Token returned from IUGU, aborting")
        raise ActiveRecord::Rollback
      end

    else
      logger.error "Bad ops_type, can't create subscription"
      errors.add(:attr, "Bad ops_type, can't create subscription")
      raise ActiveRecord::Rollback
    end
  end

  def get_sub_data
    subscription = Mconf::Iugu.get_subscription(self.subscription_token)
  end

  # Destroy the customer on OPS, if there's a customer token set in the model.
  def destroy_sub
    if self.plan.ops_type == "IUGU"
      subscription = Mconf::Iugu.destroy_subscription(self.subscription_token)

      if subscription == false
        logger.error "Could not delete subscription from OPS, aborting"
        errors.add(:attr, "Could not delete subscription from OPS, aborting")
        raise ActiveRecord::Rollback
      end

      customer = Mconf::Iugu.destroy_customer(self.customer_token)

      if customer == false
        logger.error "Could not delete customer from OPS, aborting"
        errors.add(:attr, "Could not delete customer from OPS, aborting")
        raise ActiveRecord::Rollback
      end

    else
      logger.error "Bad ops_type, can't destroy subscription"
    end
  end

end
