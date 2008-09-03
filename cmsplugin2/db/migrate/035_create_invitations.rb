class CreateInvitations < ActiveRecord::Migration
  def self.up
    create_table :invitations do |t|
      t.column  :email , :string
      t.column :space_id, :integer
      t.column :user_id, :integer
      t.column :role_id, :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :invitations
  end
end
