require "#{RAILS_ROOT}/vendor/plugins/cmsplugin/app/models/performance"
class Performance

after_create {|perfor|
  user = perfor.agent
  space = perfor.container
  role = perfor.role
  group = Group.find_by_name(space.emailize_name)
  if group
  if (role == Role.find_by_name("Admin") || role == Role.find_by_name("User")) && !group.users.include?(user)
    user_ids = []
    group.users.each do |u|
      user_ids << "#{u.id}"
    end
    user_ids << "#{user.id}"
    
    group.update_attributes(:user_ids => user_ids)
  end
  end
}

before_destroy {|perfor|
  user = perfor.agent
  space = perfor.container
  group = Group.find_by_name(space.emailize_name)
  if group
    user_ids = []
    group.users.each do |u|
      user_ids << "#{u.id}"
    end
    user_ids.delete("#{user.id}")
    
    group.update_attributes(:user_ids => user_ids)  
    end
}
  
end
