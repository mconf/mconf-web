class AddDurationToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :duration, :integer
  end
end
