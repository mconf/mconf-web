class AddGenerateScormToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :generate_scorm_at, :datetime
  end

  def self.down
    remove_column :events, :generate_scorm_at
  end
end
