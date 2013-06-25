class Timezones < ActiveRecord::Migration
  def self.up
    add_column :users, :timezone, :string, :default => 'UTC'
  end

  def self.down
    remove_column :users, :timezone
  end
end
