class AddOwnerIdToInvitations < ActiveRecord::Migration
  def up
    add_column :invitations, :owner_id, :string
  end
  def down
    remove_column :invitations, :owner_id
  end
end
