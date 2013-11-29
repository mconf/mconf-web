# Will approve all users that are already in the database. In applications already in production,
# the users already created should be approved, otherwise they won't be able to access the website.

class ApproveAllUsers < ActiveRecord::Migration
  def up
    User.update_all(:approved => true)
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
