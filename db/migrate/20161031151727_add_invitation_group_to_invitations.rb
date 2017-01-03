class AddInvitationGroupToInvitations < ActiveRecord::Migration
  def up
    add_column :invitations, :invitation_group, :string
  end
  def down
    remove_column :invitations, :invitation_group
  end
end
