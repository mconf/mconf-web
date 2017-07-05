# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class Iugu

###SUBSCRIPTION##########################################################################################
    # We will have to create a customer here to link to a subscription
    def self.create_subscription(plan_id, customer_id, pay_day)
      subscription = ::Iugu::Subscription.create({
        plan_identifier: plan_id,
        customer_id: customer_id,
        expires_at: pay_day
      })

      subscription.attributes["id"]
    end

    # Upon changing/destroying subscription we will also destroy the customer
    def self.destroy_subscription(subscription_id)
      subscription = ::Iugu::Subscription.fetch(subscription_id)
      subscription.delete
    end

    def self.get_subscription(subscription_id)
      subscription = ::Iugu::Subscription.fetch(subscription_id)
      subscription
    end

###CUSTOMER#############################################################################################
    # We must create a customer account on Iugu when an user signs a subscription plan  
    def self.create_customer(email, full_name, cpf_cnpj, zipcode, address, city, province, country)

      customer = ::Iugu::Customer.create({
        email: email,
        name: full_name,
        cpf_cnpj: cpf_cnpj,
        zip_code: zipcode,
        number: address,
        street: address,
        city: city,
        state: province,
        custom_variables: [ name: "Country", identifier: "country", value: country ]
      })

      customer.attributes["id"]
    end

    # We should delete a customer when his account is destroyed
    def self.destroy_customer(customer_id)
      customer = ::Iugu::Customer.fetch(customer_id)
      customer.delete
    end

###PLAN#################################################################################################
    def self.create_plan(name, identifier, currency, interval, interval_type, item_price, base_price)
      plan = ::Iugu::Plan.create({
        name: name,
        identifier: identifier,
        interval: interval,
        interval_type: interval_type,
        currency: currency,
        value_cents: base_price,
        payable_with: "all",
        features: [ { name: "Price per user", identifier: "user_price", value: item_price } ]
      })

      plan.attributes["id"]
    end

    def self.destroy_plan(plan_id)
      plan = ::Iugu::Plan.fetch(plan_id)
      plan.delete
    end

    # Get the plans from Iugu to the db on a new server
    def self.fetch_all_plans
      plans = ::Iugu::Plan.fetch()
      plans
    end
########################################################################################################

  end
end
