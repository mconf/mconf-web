#
# Some activities created before 0866e853a6eee had no recipient_id/recipient_type.
# This migration adds this data to the models as precisely as we can from the other data.
#
# The affect keys are attachment[created, destroyed], user.created,
# event.[created, updated], join_request.[request invite], bigbluebutton_meeting.create
#
class MigrateRecentActivityRecipients < ActiveRecord::Migration
  def up
    scope = RecentActivity.where(recipient_id: nil)

    scope.where(key: 'user.created').each do |act|
      act.update_attributes(recipient: act.trackable)
    end

    scope.where(key: ['attachment.create', 'attachment.destroy']).each do |act|
      # Set the recipient to the author or the an admin of the space.
      # The second case will only happen if the attachment was deleted.
      user = act.trackable.try(:author) || act.owner.try(:admins).try(:first)

      act.update_attributes(recipient: user)
    end

    scope.where(key: ['event.create', 'event.update']).each do |act|
      user = User.find(act.parameters[:user_id]) if act.parameters[:user_id].present?

      if user.present?
        act.update_attributes(recipient: user)
      else
        act.update_attributes(recipient: act.owner)
      end
    end

    scope.where(key: ["join_request.request", "join_request.invite"]).each do |act|
      act.update_attributes(recipient_id: act.parameters[:candidate_id], recipient_type: 'User')
    end

    scope.where(key: "bigbluebutton_meeting.create").each do |act|
      owner = act.owner.owner # act.owner is the room, room.owner is a user/space

      # If owner is not an user, get the admin of the space
      if owner.class == Space
        owner = owner.try(:admins).try(:first)
      end

      act.update_attributes(recipient: owner)
    end

  end

  def down
    # No turning back
  end
end
