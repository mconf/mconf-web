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

  def post_invoice_to_ops(unit_value, quantity )
    if self.subscription.plan.ops_type == "IUGU"
      #do teh math
    else
      logger.error "Bad ops_type, can't update customer"
      errors.add(:ops_error, "Bad ops_type, can't update customer")
      raise ActiveRecord::Rollback
    end
  end


  def generate_invoice_value
    # Make sure we are updated and also that we are working with the correct month
    update_unique_user_qty
    if unique_total < 15
      Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.subscriptions.minimum_fee'), "9000", "1")
    elsif unique_total < 250
      Mconf::Iugu.add_invoice_item(self.subscription_token, I18n.t('.subscriptions.user_fee'), "600", unique_total)
    end
  end

end
