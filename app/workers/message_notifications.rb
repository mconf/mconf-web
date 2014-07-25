class MessageNotifications
  @queue = :message_notifications

  # Finds all message recent activity and sends their users the message notifications
  def self.perform
    @activities = RecentActivity.where(
      :notified => [nil,false], :trackable_type => 'PrivateMessage', :key => 'private_message.received')

    @activities.each do |a|
      receiver = a.owner
      sender_name = a.parameters['sender_name']
      digest = a.parameters['digest_type']
      notification = a.parameters['notification_type']

      # still missing digest logic
      if notification == User::NOTIFICATION_VIA_EMAIL
        Resque.logger "Sending email to #{receiver.email}. Message from #{sender_name}.\n"
        # TODO: actually send email
      end # else there's no need to notify via email

      a.notified = true
      a.save!
    end
  end

end
