class CreateStatistics < ActiveRecord::Migration
  def self.up
    create_table :statistics do |t|
      t.string :url
      t.integer :unique_pageviews

      t.timestamps
    end
  end

  def self.down
    drop_table :statistics
  end
end
