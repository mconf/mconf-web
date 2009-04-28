class CreateAdmissions < ActiveRecord::Migration
  def self.up
    drop_table :invitations

    create_table :admissions do |t|
      t.string  :type
      t.integer :candidate_id
      t.string  :candidate_type
      t.string  :email
      t.integer :group_id
      t.string  :group_type
      t.integer :role_id
      t.string  :code
      t.timestamps
      t.datetime :accepted_at
    end
  end

  def self.down
    drop_table :admissions

    create_table :invitations do |t|
      t.string   :email
      t.integer  :stage_id
      t.integer  :agent_id
      t.integer  :role_id
      t.datetime :created_at
      t.datetime :updated_at
      t.string   :stage_type
      t.string   :agent_type
      t.string   :acceptation_code
      t.datetime :accepted_at
    end
  end
end
