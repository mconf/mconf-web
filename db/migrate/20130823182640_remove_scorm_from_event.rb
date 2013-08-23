class RemoveScormFromEvent < ActiveRecord::Migration
  def up
    remove_column :events, :generate_scorm_at
  end

  def down
    add_column :events, :generate_scorm_at, :datetime
  end
end
