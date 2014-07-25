class AddNotifiedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :notified, :boolean
  end
end
