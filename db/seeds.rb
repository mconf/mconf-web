# This file should contain all the record creation needed to seed the
# database with its default values. The data can then be loaded with
# the rake db:seed (or created alongside the db with db:setup).

puts "* Create the default site"
puts "  attributes read from the configuration file:"
puts "    #{configatron.site.to_hash.inspect}"
puts "  smtp configurations defaults to Gmail if not set"

params = { # smtp configs for gmail
  :smtp_auto_tls => true,
  :smtp_server => "smtp.gmail.com",
  :smtp_port => 587,
  :smtp_use_tls => true,
  :smtp_domain => "gmail.com",
  :smtp_auth_type => :plain,
  :domain => 'mconf-example.com'
}
params.merge!(configatron.site.to_hash)
params[:smtp_sender] ||= params[:smtp_login]

if Site.count > 0
  Site.current.update_attributes params
else
  Site.create! params
end


puts "* Create the default webconference server"
puts "  attributes read from the configuration file:"
puts "    #{configatron.webconf_server.to_hash.inspect}"

params = configatron.webconf_server.to_hash
if BigbluebuttonServer.count > 0
  BigbluebuttonServer.first.update_attributes params
else
  BigbluebuttonServer.create! params
end


puts "* Create default roles"
Role.create! :name => 'User', :stage_type => 'Space'
Role.create! :name => 'Admin', :stage_type => 'Space'
Role.create! :name => 'Organizer', :stage_type => 'Event'


puts "* Create the administrator account"
puts "  attributes read from the configuration file:"
puts "    #{configatron.admin.to_hash.inspect}"

params = configatron.admin.to_hash
params[:superuser] = true
params[:password_confirmation] ||= params[:password]
params[:_full_name] ||= params[:username]
profile = params.delete(:profile_attributes)

u = User.new params
u.skip_confirmation!
u.approved = true
if u.save(:validate => false)
  u.profile.update_attributes(profile.to_hash) unless profile.nil?
else
  puts "ERROR!"
  puts u.errors.inspect
end

puts "* db:seed finished successfully"
