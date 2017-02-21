class MigrateSuperuserFieldToPermission < ActiveRecord::Migration
  def up
    if Site::roles[:admin].blank?
      Role.create! name: 'Global Admin', stage_type: 'Site'
    end

    User.find_each do |u|
      if u.read_attribute(:superuser) == true
        Permission.create(subject: Site.current, role: Site.roles[:admin], user: u)
        puts "* Creating permission for global admin: #{u.username}"
      end
    end
  end

  def down
    User.find_each do |u|
      p = Permission.find_by(user: u, subject: Site.current)
      if p.present?
        p.destroy
        u.update_attribute(:superuser, true)
        puts "* Deleting permission and restoring data for global admin: #{p.user.username}"
      end
    end
  end

end
