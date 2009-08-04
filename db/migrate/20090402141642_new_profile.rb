class NewProfile < ActiveRecord::Migration
  def self.up
    remove_column :profiles, :name
    remove_column :profiles, :lastname
  end

  def self.down
    add_column :profiles, :name, :string
    add_column :profiles, :lastname, :string
  end
end
