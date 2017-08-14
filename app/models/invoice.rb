# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Invoice < ActiveRecord::Base
  belongs_to :subscription

  validates :subscription_id, :presence => true

  # This model has these attributes:
  #  :subscription_id
  #  :invoice_token
  #  :invoice_url
  #  :flag_invoice_status
  #  :due_date
  #  :user_qty
  #  :invoice_value

  def get_stats_for_subscription
    server = BigbluebuttonServer.default
    server.api.send_api_request(:getStats, { meetingID: self.subscription.user.bigbluebutton_room.meetingid })
  end

  def update_unique_user_qty
    get_stats = get_stats_for_subscription
    begin
      if get_stats.present?
        all_meetings = get_stats[:stats][:meeting]
        # Make it an array if it is not
        all_meetings = [all_meetings] unless all_meetings.is_a?(Array)
        # Reject all recordings older than the beginning of last month
        this_month = all_meetings.reject { |meet| Time.at(meet[:epochStartTime].to_i/1000) < (due_date.at_beginning_of_month.last_month.to_i) }
        # Reject all recordings that happened in the new month
        this_month = this_month.reject { |meet| Time.at(meet[:epochStartTime].to_i/1000) > (due_date.at_end_of_month.last_month.to_i) }
        # Get all users in the defined interval
        list_users = this_month.map { |meeting| meeting[:participants][:participant] }.flatten.map { |participant| participant[:userName] }
        # We must replace uniq with the name deduplicator algorithm
        unique_user = list_users.uniq
        unique_total = unique_user.count

        update_attributes(user_qty: unique_total)
      else
        logger.error "get_stats API call has failed"
        raise "get_stats error"
      end
    rescue BigBlueButton::BigBlueButtonException
      logger.error "get_stats API call has failed"
      raise "get_stats error"
    end
  end

  def post_invoice_to_ops

    data = generate_invoice_value
    cost = data[:cost]
    disc = -(data[:discount] * cost)
    quan = data[:quantity]
    if quantity < 15
      Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.invoices.minimum_fee'), cost, quantity)
    else
      Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.invoices.user_fee'), cost, quantity)
      Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.invoices.user_fee'), disc, quantity)
    end
  end


  def generate_invoice_value
    #move to initializer to make @s after initilaize
    b_price = config.base_price
    b_price_i = config.base_price_integrator

    # Make sure we are updated and also that we are working with the correct month
    update_unique_user_qty

    result = {
      discounts: {},
      quantity: self.user_qty
    }

    # disconto por usuário
    config.discounts.reverse_each do |discount|
      if self.user_qty >= discount[:users] && !result[:discounts].has_key?(:users)
        result[:discounts][:users] = discount[:value]
      end
    end

    # custo conforme tipo e cliente
    result[:cost_per_user] = self.subscription.integrator ? b_price_i : b_price

    # consumo conforme dias do mês consumidos
    if self.days_consumed < config.base_month_days
      result[:discounts][:days] = self.days_consumed / config.base_month_days
    end

    # calcula preço final considerando tarifa mínima
    if self.user_qty < config.minimum_users
      total = result[:cost_per_user] * config.minimum_users
      total *= result[:days] if result[:discounts].has_key?(:days)

      result[:total] = total
      result[:minimum] = true
    else
      cost = result[:price] * self.user_qty
      total = result.has_key?(:discount_users) ? cost * (1.0 - result[:discount]) : 0
      total *= result[:days] if result[:discounts].has_key?(:days)

      result[:total] = total
      result[:minimum] = false
    end

    update_attributes(invoice_value: result[:total])
    result


#    if self.subscription.integrator
#      if self.user_qty < 15
#        cost = config.m_price_i
#        final = cost
#        update_attributes(invoice_value: final)
#        { cost: m_price_i, quantity: self.user_qty }
#      elsif self.user_qty < 251
#        final = (b_price_i * self.user_qty)
#        update_attributes(invoice_value: final)
#        { cost: b_price_i, quantity: self.user_qty }
#      elsif self.user_qty < 501
#        cost = (b_price_i * self.user_qty)
#        discount = (b_price_i * d_250 * self.user_qty)
#        final = cost - discount
#        update_attributes(invoice_value: final)
#        { cost: b_price_i, discount: d_250, quantity: self.user_qty }
#      elsif self.user_qty < 1001
#        cost = (b_price_i * self.user_qty)
#        discount = (b_price_i * d_500 * self.user_qty)
#        final = cost - discount
#        update_attributes(invoice_value: final)
#        { cost: b_price_i, discount: d_500, quantity: self.user_qty }
#      elsif self.user_qty < 2501
#        cost = (b_price_i * self.user_qty)
#        discount = (b_price_i * d_1000 * self.user_qty)
#        final = cost - discount
#        update_attributes(invoice_value: final)
#        { cost: b_price_i, discount: d_1000, quantity: self.user_qty }
#      elsif self.user_qty < 5001
#        cost = (b_price_i * self.user_qty)
#        discount = (b_price_i * d_2500 * self.user_qty)
#        final = cost - discount
#        update_attributes(invoice_value: final)
#        { cost: b_price_i, discount: d_2500, quantity: self.user_qty }
#      else
#        cost = (b_price_i * self.user_qty)
#        discount = (b_price_i * d_5000 * self.user_qty)
#        final = cost - discount
#        update_attributes(invoice_value: final)
#        { cost: b_price_i, discount: discount_5000, quantity: self.user_qty }
#      end
#
#    else
#      if self.user_qty < 15
#        final = config.m_price
#        update_attributes(invoice_value: final)
#        { cost: m_price, quantity: self.user_qty }
#      elsif self.user_qty < 251
#        final = (b_price * self.user_qty)
#        update_attributes(invoice_value: final)
#        { cost: b_price, quantity: self.user_qty }
#      elsif self.user_qty < 501
#        cost = (b_price * self.user_qty)
#        discount = (b_price * d_250 * self.user_qty)
#        final = cost - discount
#        update_attributes(invoice_value: final)
#        { cost: b_price, discount: d_250, quantity: self.user_qty }
#      elsif self.user_qty < 1001
#        cost = (b_price * self.user_qty)
#        discount = (b_price * d_500 * self.user_qty)
#        final = cost - discount
#        update_attributes(invoice_value: final)
#        { cost: b_price, discount: d_500, quantity: self.user_qty }
#      elsif self.user_qty < 2501
#        cost = (b_price * self.user_qty)
#        discount = (b_price * d_1000 * self.user_qty)
#        final = cost - discount
#        update_attributes(invoice_value: final)
#        { cost: b_price, discount: d_1000, quantity: self.user_qty }
#      elsif self.user_qty < 5001
#        cost = (b_price_i * self.user_qty)
#        discount = (b_price * d_2500 * self.user_qty)
#        final = cost - discount
#        update_attributes(invoice_value: final)
#        { cost: b_price, discount: d_2500, quantity: self.user_qty }
#      else
#        cost = (b_price_i * self.user_qty)
#        discount = (b_price * d_5000 * self.user_qty)
#        final = cost - discount
#        update_attributes(invoice_value: final)
#        { cost: b_price, discount: d_5000, quantity: self.user_qty }
#      end
#    end
  end

end
