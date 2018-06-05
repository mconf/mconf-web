# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class Iugu

###SUBSCRIPTION##########################################################################################
    # Creates a subscription, needs a plan and costumer to exist since it's a relation between such
    def self.create_subscription(plan_identifier, customer_id, pay_day)
      subscription = ::Iugu::Subscription.create({
        plan_identifier: plan_identifier,
        customer_id: customer_id,
        expires_at: pay_day
      })

      subscription.attributes["id"]
    end

    # Adds the actual invoice value to the current month subscription
    def self.add_invoice_item(subscription_id, description, price_cents_unit, quantity)
      subscription = ::Iugu::Subscription.fetch(subscription_id)
      subscription.subitems = [ description: description, price_cents: price_cents_unit, quantity: quantity ]
      subscription.save
    end

    def self.get_invoice_items(subscription_id)
      subscription = ::Iugu::Subscription.fetch(subscription_id)
      subscription.subitems
    end

    # Upon changing/destroying subscription we will also destroy the customer
    def self.destroy_subscription(subscription_id)
      subscription = ::Iugu::Subscription.fetch(subscription_id)
      subscription.delete
    end

    # We might want to just suspend the subscription without deleting to keep db relations
    def self.disable_subscription(subscription_id)
      subscription = ::Iugu::Subscription.fetch(subscription_id)
      if subscription.suspended == false
        subscription.suspend
      end
    end

    # We might want to just reactivate the subscription with the same data as before
    def self.enable_subscription(subscription_id)
      subscription = ::Iugu::Subscription.fetch(subscription_id)
      if subscription.suspended == true
        subscription.activate
      end
    end

    # This will just return the data of a given subscription
    def self.get_subscription(subscription_id)
      subscription = ::Iugu::Subscription.fetch(subscription_id)
      subscription
    end

    def self.fetch_all_subscriptions
      subscriptions = ::Iugu::Subscription.fetch
      subscriptions.results
    end

###INVOICES#############################################################################################

    # This returns an array of invoices for a given user token
    # The array contains an @attributes hash with all info we need to create the list
    def self.fetch_user_invoices(customer_id)
      invoices = ::Iugu::Invoice.search(customer_id: customer_id).results
      invoices
    end

    def self.fetch_invoice(invoice_token)
      invoice = ::Iugu::Invoice.fetch(invoice_token)
      invoice
    end

###CUSTOMER#############################################################################################
    # We must create a customer account on Iugu when an user signs a subscription plan  
    def self.create_customer(email, full_name, cpf_cnpj, address, additional_address_info, number,
                             zipcode, city, province, district, country)

      customer = ::Iugu::Customer.create({
        email: email,
        name: full_name,
        cpf_cnpj: cpf_cnpj,
        zip_code: zipcode,
        number: number,
        street: address,
        city: city,
        state: province,
        district: district,
        complement: additional_address_info,
        custom_variables: [ name: "Country", identifier: "country", value: country ]
      })

      if customer.errors.present?
        customer.errors
      else
        customer.attributes["id"]
      end
    end

    # Currently not going to upate full_name or email, subscription must be created over to change those fields
    # def self.update_customer(customer_id, cpf_cnpj, address, additional_address_info, number, zipcode, city, province, district, email)
    def self.update_customer(customer_id, params)
      customer = ::Iugu::Customer.fetch(customer_id)
      customer.cpf_cnpj = params[:cpf_cnpj] if params.key?(:cpf_cnpj)
      customer.zip_code = params[:zipcode] if params.key?(:zipcode)
      customer.number = params[:number] if params.key?(:number)
      customer.street = params[:address] if params.key?(:address)
      customer.city = params[:city] if params.key?(:city)
      customer.state = params[:province] if params.key?(:province)
      customer.district = params[:district] if params.key?(:district)
      customer.complement = params[:additional_address_info] if params.key?(:additional_address_info)
      customer.email = params[:email] if params.key?(:email)

      customer.save

      if customer.errors.present?
        customer.errors
      else
        customer.save
      end
    end

    # We should delete a customer when his account is destroyed
    def self.destroy_customer(customer_id)
      customer = ::Iugu::Customer.fetch(customer_id)
      customer.delete
    end

    def self.find_customer_by_id(customer_id)
      customer = ::Iugu::Customer.fetch(customer_id)
      customer
    end

###PLAN#################################################################################################
    def self.create_plan(name, identifier, currency, interval, interval_type)
      plan = ::Iugu::Plan.create({
        name: name,
        identifier: identifier,
        interval: interval,
        interval_type: interval_type,
        currency: currency,
        value_cents: 0,
        payable_with: "all"
      })

      plan.attributes["id"]
    end

    def self.destroy_plan(plan_token)
      plan = ::Iugu::Plan.fetch(plan_token)
      plan.delete
    end

    # Get the plans from Iugu
    def self.fetch_all_plans
      plans = ::Iugu::Plan.fetch
      plans.results
    end

###TEST#SCRIPTS#########################################################################################

    # Since Iugu doesn't support dropping the test DB these scripts will do the trick
    # Should not be used on production DB to avoid loss of data and inconsistency on IUGU reports

    # def self.drop_subscriptions
    #   subscriptions = ::Iugu::Subscription.fetch()
    #   subscriptions.results.each do |sub|
    #     puts ::Iugu::Subscription.fetch(sub.attributes['id']).delete
    #   end
    # end

    # def self.drop_customers
    #   customer = ::Iugu::Customer.fetch()
    #   customer.results.each do |cus|
    #     puts ::Iugu::Customer.fetch(cus.attributes['id']).delete
    #   end
    # end

########################################################################################################

  end
end
