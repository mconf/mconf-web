class AddFieldsToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :prefix, :string
    add_column :profiles, :description, :text
    add_column :profiles, :url, :string
    add_column :profiles, :skype, :string
    add_column :profiles, :im, :string
    add_column :profiles, :visibility, :integer, :default => Profile::VISIBILITY.index(:public_fellows)
  end

  def self.down
    remove_column :profiles, :prefix
    remove_column :profiles, :description
    remove_column :profiles, :url
    remove_column :profiles, :skype
    remove_column :profiles, :im
    remove_column :profiles, :visibility
  end
end
