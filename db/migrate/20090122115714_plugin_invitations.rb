class PluginInvitations < ActiveRecord::Migration
  def self.up
    rename_column :invitations, :space_id, :stage_id
    add_column    :invitations, :stage_type, :string
    rename_column :invitations, :user_id, :agent_id
    add_column    :invitations, :agent_type, :string
    add_column    :invitations, :acceptation_code, :string
    add_column    :invitations, :accepted_at, :datetime

    Invitation.record_timestamps = false
    Invitation.all.each do |i|
      i.stage_type = "Space"
      i.agent_type = "User"
      i.save!
    end
  end

  def self.down
    remove_column :invitations, :code
    rename_column :invitations, :stage_id, :space_id
    remove_column :invitations, :stage_type
    rename_column :invitations, :agent_id, :user_id
    remove_column :invitations, :agent_type
    remove_column :invitations, :acceptation_code
    remove_column :invitations, :accepted_at
  end
end
