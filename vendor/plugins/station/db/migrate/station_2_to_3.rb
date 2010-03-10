class Station2To3 < ActiveRecord::Migration
  def self.up
    create_table :admissions do |t|
      t.string     :type
      t.references :candidate,  :polymorphic => true
      t.references :group,      :polymorphic => true
      t.references :introducer, :polymorphic => true
      t.string     :email
      t.references :role
      t.text       :comment
      t.string     :code
      t.boolean    :accepted

      t.timestamps
      t.datetime   :processed_at
    end

    create_table :source_importations do |t|
      t.references :source
      t.references :importation, :polymorphic => true
      t.references :uri
      t.string     :guid
      t.timestamps
    end

    create_table :sources do |t|
      t.references :uri
      t.string     :content_type
      t.string     :target
      t.references :container, :polymorphic => true
      t.datetime   :imported_at
      t.timestamps
    end
   end
 
  def self.down
    drop_table :admissions
    drop_table :source_importations
    drop_table :sources
  end
end
