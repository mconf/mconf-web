class CreateInvitations < ActiveRecord::Migration
  def up
    create_table :invitations do |t|
      t.belongs_to :target, :polymorphic => true
      t.belongs_to :from
      t.string  :type
      t.string  :title
      t.text    :description
      t.string  :url
      t.datetime  :starts_on
      t.datetime  :ends_on
      t.timestamps
    end

    add_index :invitations, [:target_id, :target_type]
  end

  def down
    drop_table :invitations
  end
end
