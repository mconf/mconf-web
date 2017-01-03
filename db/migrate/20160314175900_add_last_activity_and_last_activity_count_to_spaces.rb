class AddLastActivityAndLastActivityCountToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :last_activity, :datetime
    add_column :spaces, :last_activity_count, :integer

    add_index :spaces, :last_activity
    add_index :spaces, :last_activity_count
  end

end
