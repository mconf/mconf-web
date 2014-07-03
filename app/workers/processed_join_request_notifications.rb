class ProcessedJoinRequestNotifications
  @queue = :processed_join_request_notifications

  # Finds all join requests accepted on recent activity and sends to the users the notifications
  def self.perform
    processed_request_notifications
  end

  # Notifies the user when his membership requests are accepted
  # ONLY FOR JOIN REQUESTS YET
  def self.processed_request_notifications
    requests = RecentActivity.where :trackable_type => 'Space', :key => 'space.join', :notified => [nil,false]

    requests.each do |activity|
      join_request = JoinRequest.find(activity.parameters[:join_request_id])
      user = join_request.candidate

      if user.notification == User::NOTIFICATION_VIA_EMAIL
        Resque.logger << "Sending notification to user #{user.email}.\n"
        SpaceMailer.processed_join_request_email(join_request.id).deliver
      else
        # notify via the website
      end

      activity.notified = true
      activity.save!
    end
  end

end
