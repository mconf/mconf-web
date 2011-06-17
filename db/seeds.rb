# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

puts "* Create the default site"
puts "  name: #{configatron.site.name}"
puts "  description: #{configatron.site.description}"
puts "  email: #{configatron.site.email}"
puts "  locale: #{configatron.site.locale}"
puts "  domain: #{configatron.site.domain}"
u = Site.create :name => configatron.site.name,
                :description => configatron.site.description,
                :email => configatron.site.email,
                :locale => configatron.site.locale,
                :domain => configatron.site.domain

puts "* Create the administrator account"
puts "  login: #{configatron.admin.login}"
puts "  email: #{configatron.admin.email}"
puts "  password: #{configatron.admin.password}"
puts "  fullname: #{configatron.admin.fullname}"
u = User.create :login => configatron.admin.login,
                :email => configatron.admin.email,
                :password => configatron.admin.password,
                :password_confirmation => configatron.admin.password
u.update_attribute(:superuser,true)
u.activate
u.profile!.update_attribute(:full_name, configatron.admin.fullname)

puts "* Create Permissions"

# Permissions without objective
%w( read update delete translate ).each do |action|
  Permission.find_or_create_by_action_and_objective action, nil
end

# Permissions applied to Content and Performance
%w( create read update delete ).each do |action|
  %w( content performance ).each do |objective|
    Permission.find_or_create_by_action_and_objective action, objective
  end
end

Permission.find_or_create_by_action_and_objective "update", "attachment"

# Permission applied to Group
Permission.find_or_create_by_action_and_objective "manage", "group"
# Permission to start an event
Permission.find_or_create_by_action_and_objective "start", "event"


puts "* Create Roles"

translator_role = Role.find_or_create_by_name_and_stage_type "Translator", "Site"
translator_role.permissions << Permission.find_by_action_and_objective('translate', nil)

organizer_role = Role.find_or_create_by_name_and_stage_type "Organizer", "Event"
organizer_role.permissions << Permission.find_by_action_and_objective('read', nil)
organizer_role.permissions << Permission.find_by_action_and_objective('update', nil)
organizer_role.permissions << Permission.find_by_action_and_objective('create', 'content')
organizer_role.permissions << Permission.find_by_action_and_objective('read',   'content')
organizer_role.permissions << Permission.find_by_action_and_objective('update', 'content')
organizer_role.permissions << Permission.find_by_action_and_objective('delete', 'content')
organizer_role.permissions << Permission.find_by_action_and_objective('start', 'event')

invitedevent_role = Role.find_or_create_by_name_and_stage_type "Invitedevent", "Event"
invitedevent_role.permissions << Permission.find_by_action_and_objective('read', nil)

speaker_role = Role.find_or_create_by_name_and_stage_type "Speaker", "AgendaEntry"
speaker_role.permissions << Permission.find_by_action_and_objective('read', nil)
speaker_role.permissions << Permission.find_by_action_and_objective('update', nil)

admin_role = Role.find_or_create_by_name_and_stage_type "Admin", "Space"
admin_role.permissions << Permission.find_by_action_and_objective('read',   nil)
admin_role.permissions << Permission.find_by_action_and_objective('update', nil)
admin_role.permissions << Permission.find_by_action_and_objective('delete', nil)
admin_role.permissions << Permission.find_by_action_and_objective('create', 'content')
admin_role.permissions << Permission.find_by_action_and_objective('read',   'content')
admin_role.permissions << Permission.find_by_action_and_objective('update', 'content')
admin_role.permissions << Permission.find_by_action_and_objective('delete', 'content')
admin_role.permissions << Permission.find_by_action_and_objective('create', 'performance')
admin_role.permissions << Permission.find_by_action_and_objective('read',   'performance')
admin_role.permissions << Permission.find_by_action_and_objective('update', 'performance')
admin_role.permissions << Permission.find_by_action_and_objective('delete', 'performance')
admin_role.permissions << Permission.find_by_action_and_objective('manage', 'group')

user_role = Role.find_or_create_by_name_and_stage_type "User", "Space"
user_role.permissions << Permission.find_by_action_and_objective('read',   nil)
user_role.permissions << Permission.find_by_action_and_objective('create', 'content')
user_role.permissions << Permission.find_by_action_and_objective('read',   'content')
user_role.permissions << Permission.find_by_action_and_objective('update', 'attachment')
user_role.permissions << Permission.find_by_action_and_objective('create', 'performance')
user_role.permissions << Permission.find_by_action_and_objective('read',   'performance')

invited_role = Role.find_or_create_by_name_and_stage_type "Invited", "Space"
invited_role.permissions << Permission.find_by_action_and_objective('read', nil)
invited_role.permissions << Permission.find_by_action_and_objective('read', 'content')
invited_role.permissions << Permission.find_by_action_and_objective('read', 'performance')

puts "* Create the default space:"
puts "  name: #{configatron.default_space.name}"
puts "  description: #{configatron.default_space.description}"
default_space = Space.create :name => configatron.default_space.name,
                             :description => configatron.default_space.description,
                             :public => true,
                             :default_logo => "models/front/space.png"

puts "* Create the default BigBlueButton server"
puts "  name: #{configatron.bbb_server.name}"
puts "  url: #{configatron.bbb_server.url}"
puts "  salt: #{configatron.bbb_server.salt}"
puts "  version: #{configatron.bbb_server.version}"
bbb_server = BigbluebuttonServer.create :name => configatron.bbb_server.name,
                                        :url => configatron.bbb_server.url,
                                        :salt => configatron.bbb_server.salt,
                                        :version => configatron.bbb_server.version

puts "* Create the BigBlueButton room for the default space"
BigbluebuttonRoom.create :name => default_space.name,
                         :meetingid => default_space.permalink,
                         :server => bbb_server,
                         :owner => default_space,
                         :private => false,
                         :logout_url => "/spaces/#{default_space.permalink}"

