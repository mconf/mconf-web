class AddFeedbackUrlToSites < ActiveRecord::Migration
  def self.up
    add_column :sites, :feedback_url, :string
  end

  def self.down
    remove_column :sites, :feedback_url
  end
end
