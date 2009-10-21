class SourcesImportations < ActiveRecord::Migration
  def self.up
    create_table :source_importations do |t|
      t.references :source
      t.references :importation, :polymorphic => true
      t.string :guid

      t.timestamps
    end

    remove_column :news, :guid
    remove_column :posts, :guid
  end

  def self.down
    drop_table :source_importations
    add_column :news, :guid, :string
    add_column :posts, :guid, :string
  end
end
