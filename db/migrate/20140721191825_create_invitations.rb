class CreateInvitations < ActiveRecord::Migration
  def up
    create_table :invitations do |t|
      t.belongs_to :target, :polymorphic => true
      t.belongs_to :sender
      t.belongs_to :recipient
      t.string     :recipient_email
      t.string     :type
      t.string     :title
      t.text       :description
      t.string     :url
      t.datetime   :starts_on
      t.datetime   :ends_on
      t.boolean    :ready, :default => false
      t.boolean    :sent, :default => false
      t.boolean    :result, :default => false
      t.timestamps
    end

    add_index :invitations, [:target_id, :target_type]
  end

  def down
    drop_table :invitations
  end
end
