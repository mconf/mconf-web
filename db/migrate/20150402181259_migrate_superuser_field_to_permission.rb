class MigrateSuperuserFieldToPermission < ActiveRecord::Migration
  def up
    if Site::roles[:admin].blank?
      Role.create! name: 'Global Admin', stage_type: 'Site'
    end

    User.all.each do |u|
      if u.read_attribute(:superuser) == true
        Permission.create(subject: Site.current, role: Site.roles[:admin], user: u)
        puts "* Creating permission for global admin: #{u.username}"
      end
    end
  end

  def down

    User.all.each do |u|
      p = Permission.where(user: u, subject: Site.current).first

      if p.present?
        p.destroy
        u.update_attribute(:superuser, true)
        puts "* Deleting permission and restoring data for global admin: #{p.user.username}"
      end
    end
  end

end
