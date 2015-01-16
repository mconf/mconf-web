class MigrateJoinedActivityToAccepted < ActiveRecord::Migration
  def up
    connection = ActiveRecord::Base.connection()
    sql = "UPDATE `activities` SET `key` = 'space.accept' WHERE `key` = 'space.join';"
    connection.execute sql
  end

  def down
    connection = ActiveRecord::Base.connection()
    sql = "UPDATE `activities` SET `key` = 'space.join' WHERE `key` = 'space.accept';"
    connection.execute sql
  end
end
