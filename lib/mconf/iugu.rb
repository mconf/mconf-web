# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

Iugu.api_key = "seuApiToken"
require 'net/http'
uri = URI.parse("https://api.iugu.com/v1/plans")

def Mconf
  class Iugu

    # We will have to create a customer here to link to a subscription
    def create_subscription()

    end

    # Upon changing/destroying subscription we will also destroy the customer
    def destroy_subscription(subscription_id)
      subscription = Iugu::Subscription.fetch(subscription_id)
      subscription.delete
    end
  
    # We must create a customer account on Iugu when an user signs a subscription plan  
    def create_customer(email, full_name, cpf_cnpj, zipcode, address, city, province, country)

      customer = Iugu::Customer.create({
        email: email,
        name: full_name,
        cpf_cnpj: cpf_cnpj,
        zip_code: zipcode,
        number: address, #verificar esse aqui melhor
        city: city,
        state: province,
        custom_variables: [ country: country ] 
      })
      
      customer["id"]
    end

    # We should delete a customer when his account is destroyed
    def destroy_customer(customer_id)
      customer = Iugu::Customer.fetch(customer_id)
      customer.delete
    end

    # We must use CURL to create and destroy the plans
    def create_plan(ops_id, currency, interval, interval_type, item_price, base_price, max_users)
      # -u seuApiToken: \
      # -d "name=Plano Básico" \
      # -d "identifier=basic_plan" \
      # -d "interval=1" \
      # -d "interval_type=months" \
      # -d "currency=BRL" \
      # -d "value_cents=1000" \
      # -d "features[][name]=Número de Usuários" \
      # -d "features[][identifier]=users" \
      # -d "features[][value]=10"
    end

    def destroy_plan(plan_id)
      #CURLSTUFF  
    end

    # Get the plans from Iugu to the db on a new server
    def fetch_plans()
      #CURLSTUFF
    end

  end
end