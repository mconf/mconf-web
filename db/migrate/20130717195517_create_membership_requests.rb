class CreateMembershipRequests < ActiveRecord::Migration
  def change
    create_table :membership_requests do |t|
      t.string     :type

      t.integer    :candidate_id
      t.integer    :introducer_id

      t.references :group, :polymorphic => true

      t.string     :email
      t.boolean    :accepted

      t.timestamps
      t.datetime   :processed_at
    end
  end
end
