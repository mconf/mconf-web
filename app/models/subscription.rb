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

  validates :pay_method, :presence => true
  validates :pay_day, :presence => true
  validates :start_day, :presence => true
  validates :trial, :presence => true

  attr_accessor :payment_token

  after_create :create_customer_and_sub
  before_destroy :destroy_sub

  def create_customer_and_sub
    if self.plan.ops_type == "IUGU"
      self.customer_token = Mconf::Iugu.create_customer(self.user.email,
                                                        self.user.full_name,
                                                        self.user.profile.cpf_cnpj,
                                                        self.user.profile.zipcode,
                                                        self.user.profile.address,
                                                        self.user.profile.city,
                                                        self.user.profile.province,
                                                        self.user.profile.country)
      self.create_sub
      
    else
      logger.error "Bad ops_type, can't create customer"
    end
  end

  def get_tokens
    # get the Customer token, subscription token and ops token 
  end
  
  # Destroy the customer on OPS, if there's a customer token set in the model.
  def destroy_sub
    if ops_type == "IUGU"
      Mconf::Iugu.destroy_subscription(:subscription_token)
      Mconf::Iugu.destroy_customer(:customer_token)
    else
      logger.error "Bad ops_type, can't destroy subscription"
    end
  end

### UNDER DEVELOPMENT ######################################################################
  def create_sub
    if valid? 
      if self.destroy_customer
        params = {
          :description => email,
          :plan => plan.stripe_id,
          :card => stripe_card_token
        }
        customer = Stripe::Customer.create(params)
        self.stripe_customer_token = customer.id
        save!
      end
    end

  end

### UNDER DEVELOPMENT ######################################################################

end