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
      if get_stats[:messageKey].present?
        logger.info "There are still no stats for this customer"
      elsif get_stats[:stats].present?
        all_meetings = get_stats[:stats][:meeting]
        # Make it an array if it is not
        all_meetings = [all_meetings] unless all_meetings.is_a?(Array)
        # Reject all recordings older than the beginning of last month
        this_month = all_meetings.reject { |meet| (meet[:epochStartTime].to_i/1000) < (due_date.at_beginning_of_month.last_month.to_i) }
        # Reject all recordings that happened in the new month
        this_month = this_month.reject { |meet| (meet[:epochStartTime].to_i/1000) > (due_date.at_end_of_month.last_month.to_i) }
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
    cost = data[:cost_per_user]
    quantity = data[:quantity]
    final_cost = (data[:total] / quantity)

    if data[:minimum]
      Mconf::Iugu.add_invoice_item(self.subscription.subscription_token, I18n.t('.invoices.minimum_fee'), cost, Rails.application.config.minimum_users)

    else
      Mconf::Iugu.add_invoice_item(self.subscription.subscription_token, I18n.t('.invoices.user_fee'), final_cost, quantity)

      if data[:discounts].has_key?(:users) && data[:discounts].has_key?(:days)
        Mconf::Iugu.add_invoice_item(self.subscription.subscription_token, I18n.t('.invoices.discount_users_and_days'), final_cost, quantity)
      elsif data[:discounts].has_key?(:users)
        Mconf::Iugu.add_invoice_item(self.subscription.subscription_token, I18n.t('.invoices.discount_users'), final_cost, quantity)
      elsif data[:discounts].has_key?(:days)
        Mconf::Iugu.add_invoice_item(self.subscription.subscription_token, I18n.t('.invoices.discount_days'), final_cost, quantity)
      end

    end
  end


  def generate_invoice_value
    #move to initializer to make @s after initilaize
    b_price =  Rails.application.config.base_price
    b_price_i =  Rails.application.config.base_price_integrator

    # Make sure we are updated and also that we are working with the correct month
    #update_unique_user_qty

    result = {
      discounts: {},
      quantity: self.user_qty
    }

    # test for 700 users
    self.update_attributes(user_qty: 700)
    # discounts for user quantity
     Rails.application.config.discounts.reverse_each do |discount|
      if self.user_qty >= discount[:users] && !result[:discounts].has_key?(:users)
        result[:discounts][:users] = discount[:value]
      end
    end

    # sets the cost for each client type
    result[:cost_per_user] = self.subscription.integrator ? b_price_i : b_price

    # discounts for days consumed
    if self.days_consumed.present? && self.days_consumed <  Rails.application.config.base_month_days
      result[:discounts][:days] = self.days_consumed /  Rails.application.config.base_month_days
    end

    #test for 15 days usage:
    result[:discounts][:days] = 0.5

    # calculates the final price for the invoice
    if self.user_qty <  Rails.application.config.minimum_users
      total = result[:cost_per_user] *  Rails.application.config.minimum_users
      total *= result[:discounts][:days] if result[:discounts].has_key?(:days)

      result[:total] = total
      result[:minimum] = true
    else
      cost = result[:cost_per_user] * self.user_qty
      total = result[:discounts].has_key?(:users) ? cost * (1.0 - result[:discounts][:users]) : cost
      total *= result[:discounts][:days] if result[:discounts].has_key?(:days)

      result[:total] = total
      result[:minimum] = false
    end

    update_attributes(invoice_value: result[:total])
    result
  end

end
