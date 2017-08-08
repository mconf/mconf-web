# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Invoice < ActiveRecord::Base
  belongs_to :subscription

  validates :subscription_id, :presence => true

    :invoice_token
    :invoice_url
    :flag_invoice_status
    :user_qty
    :due_date

#  def create_invoice
#    get_stats = get_stats_for_subscription
#    begin
#      # All of this should only happen if not during trial months
#      if get_stats.present?
#        all_meetings = get_stats[:stats][:meeting]
#        all_meetings = [all_meetings] unless all_meetings.is_a?(Array)
#        # this is scheduled for the first day of the month at 00:00, so it will be covering since the first day of last month
#        this_month = all_meetings.reject { |meet| (meet[:epochStartTime].to_i/1000) < (Time.now.to_i-1.month) }
#        list_users = this_month.map { |meeting| meeting[:participants][:participant] }.flatten.map { |participant| participant[:userName] }
#        # We must replace uniq with the name deduplicator algorithm
#        unique_user = list_users.uniq
#        unique_total = unique_user.count
#
#        if self.plan.ops_type == "IUGU"
#          if unique_total < 15
#            # Tax R$ 90,00 minimum fee
#            Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.subscriptions.minimum_fee'), "9000", "1")
#          elsif unique_total < 250
#            # Tax R$ 6,00 per user
#            Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.subscriptions.user_fee'), "600", unique_total)
#          elsif unique_total < 500
#            # Tax R$ 5,40 per user
#            Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.subscriptions.user_fee'), "540", unique_total)
#          elsif unique_total < 1000
#            # Tax R$ 4,80 per user
#            Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.subscriptions.user_fee'), "480", unique_total)
#          elsif unique_total < 2500
#            # Tax R$ 4,20 per user
#            Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.subscriptions.user_fee'), "420", unique_total)
#          elsif unique_total < 5000
#            # Tax R$ 3,60 per user
#            Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.subscriptions.user_fee'), "360", unique_total)
#          elsif unique_total > 5000
#            # Tax R$ 3,00 per user
#            Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.subscriptions.user_fee'), "300", unique_total)
#          end
#        end
#      else
#        logger.error "get_stats API call has failed"
#        raise "get_stats error"
#      end
#    rescue BigBlueButton::BigBlueButtonException
#      logger.error "get_stats API call has failed"
#      raise "get_stats error"
#    end
#  end
#
end
