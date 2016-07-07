#
# Some activities created before 0866e853a6eee had no recipient_id/recipient_type.
# This migration adds this data to the models as precisely as we can from the other data.
#
# The affect keys are attachment[created, destroyed], user.created,
# event.[created, updated], join_request.[request invite, accept, decline], bigbluebutton_meeting.create
#
class MigrateRecentActivityRecipients < ActiveRecord::Migration
  def up
    scope = RecentActivity.where(recipient_id: nil)

    puts "Migrating keys: 'user.created'"
    scope.where(key: 'user.created').find_each do |act|
      act.update_attributes(recipient: act.trackable)
    end

    puts "Migrating keys: 'attachment.create', 'attachment.destroy'"
    scope.where(key: ['attachment.create', 'attachment.destroy']).find_each do |act|
      # Set the recipient to the author or an admin of the space.
      # The second case will only happen if the attachment was deleted.
      user = act.trackable.try(:author) || act.owner.try(:admins).try(:first)

      act.update_attributes(recipient: user)
    end

    puts "Migrating keys: 'event.create', 'event.update'"
    scope.where(key: ['event.create', 'event.update']).find_each do |act|
      user = User.find_by(id: act.parameters[:user_id]) if act.parameters[:user_id].present?

      if user.present?
        act.update_attributes(recipient: user)
      else
        act.update_attributes(recipient: act.owner)
      end
    end

    puts "Migrating keys: 'join_request.request', 'join_request.invite'"
    scope.where(key: ["join_request.request", "join_request.invite"]).find_each do |act|
      act.update_attributes(recipient_id: act.parameters[:candidate_id], recipient_type: 'User')
    end

    puts "Migrating keys: 'bigbluebutton_meeting.create'"
    scope.where(key: "bigbluebutton_meeting.create").find_each do |act|
      owner = act.try(:owner).try(:owner) # act.owner is the room, room.owner is a user/space

      # If owner is not an user, get the admin of the space
      if owner && owner.class == Space
        owner = owner.try(:admins).try(:first)
      end

      act.update_attributes(recipient: owner) if owner
    end

    # accept/decline now have join_request as a trackable and the key is join_request.[accept,decline]
    puts "Migrating keys: 'space.accept', 'space.decline"
    RecentActivity.where(key: ["space.accept", "space.decline"]).find_each do |act|
      key = (act.key == "space.accept" ? 'join_request.accept' : 'join_request.decline')
      act.update_attributes(key: key)
    end
  end

  def down
    # No turning back
    raise ActiveRecord::IrreversibleMigration
  end
end
