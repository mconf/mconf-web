class CreateJoinRequests < ActiveRecord::Migration
  def change
    create_table :join_requests do |t|
      t.string     :request_type

      t.integer    :candidate_id
      t.integer    :introducer_id

      t.references :group, :polymorphic => true

      t.string     :comment

      t.references :role

      t.string     :email
      t.boolean    :accepted

      t.timestamps
      t.datetime   :processed_at
    end
  end
end
