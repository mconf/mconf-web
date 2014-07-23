class JoinRequestNotifications
  @queue = :join_request_notifications

  # Finds all join requests recent activity and sends their users the message notifications
  def self.perform
    request_notifications
    invite_notifications
  end

  # Notifies a user of membership invites
  def self.invite_notifications
    invites = RecentActivity.where :trackable_type => 'JoinRequest', :key => 'join_request.invite', :notified => [nil,false]

    invites.each do |activity|
      invite = activity.trackable
      user = invite.candidate

      if user.notification == User::NOTIFICATION_VIA_EMAIL
        Resque.logger << "Sending invite notification to #{user.email}.\n"
        SpaceMailer.invitation_email(invite.id).deliver
      else
        # TODO: notify via website
      end

      activity.notified = true
      activity.save!
    end
  end

  # Notifies the admins of spaces when a user requests membership
  def self.request_notifications
    requests = RecentActivity.where :trackable_type => 'JoinRequest', :key => 'join_request.request', :notified => [nil,false]

    requests.each do |activity|
      space = activity.owner

      # notify each space admin
      space.admins.each do |admin|
        if admin.notification == User::NOTIFICATION_VIA_EMAIL
          Resque.logger << "Sending request notification to admin #{admin.email}.\n"
          SpaceMailer.join_request_email(activity.trackable.id, admin.id).deliver
        else
          # TODO: notify via the website
        end
      end

      activity.notified = true
      activity.save!
    end
  end

end
