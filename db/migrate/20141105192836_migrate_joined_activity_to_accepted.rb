class MigrateJoinedActivityToAccepted < ActiveRecord::Migration
  def up
    RecentActivity.where(:key => 'space.join').each do |act|
      puts "Converting :join activity to :accept id: #{act.id}"
      act.update_attributes :key => 'space.accept'
    end
  end

  def down
    RecentActivity.where(:key => 'space.accept').each do |act|
      puts "Converting :accept activity to :join id: #{act.id}"
      act.update_attributes :key => 'space.join'
    end
  end
end
