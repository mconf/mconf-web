class AddExternalParticipation < ActiveRecord::Migration
  def self.up
    add_column :events, :other_participation_url, :text
  end

  def self.down
    remove_column :events, :other_participation_url
  end
end
