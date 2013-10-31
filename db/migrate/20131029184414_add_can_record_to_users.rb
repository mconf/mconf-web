class AddCanRecordToUsers < ActiveRecord::Migration
  def change
    add_column :users, :can_record, :boolean
  end
end
