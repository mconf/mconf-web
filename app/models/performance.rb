require "#{RAILS_ROOT}/vendor/plugins/cmsplugin/app/models/performance"
class Performance

after_create {|perfor|
  user = perfor.agent
  space = perfor.container
  role = perfor.role
  group = Group.find_by_name(space.emailize_name)
  if (role == Role.find_by_name("Admin") || role == Role.find_by_name("User")) && !group.users.include?(user)
    group.users << user    
  end
}

before_destroy {|perfor|
  user = perfor.agent
  space = perfor.container
  group = Group.find_by_name(space.emailize_name)
  group.users.delete(user)    
}
  
end
