#
# Include here any configuration specific the stage: PRODUCTION
#

# Prompt to make really sure we want to deploy into production
# By http://www.pastbedti.me/2009/01/handling-a-staging-environment-with-capistrano-rails/
puts "\n\e[0;31m"
puts "   ######################################################################"
puts "          Are you REALLY sure you want to deploy to PRODUCTION ?"
puts "           Enter [y/Y] to continue or anything else to cancel"
puts "   ######################################################################"
puts "\e[0m\n"
proceed = STDIN.gets[0..0] rescue nil
unless proceed == 'y' || proceed == 'Y'
  puts "Aborting..."
  exit
end

# Load values from the config file
configs[stage.to_s].each do |hash_key, hash_value|
  set(hash_key.to_sym, hash_value.to_s)
end

role :app, fetch(:server)
role :web, fetch(:server)
role :db, fetch(:server), :primary => true




