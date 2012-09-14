# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

#
# Include here any configuration specific the stage: PRODUCTION
#

# confirm before any action
after 'deploy:info', 'deploy:confirm'

# Load values from the config file
configs[stage.to_s].each do |hash_key, hash_value|
  set(hash_key.to_sym, hash_value.to_s)
end

role :app, fetch(:server)
role :web, fetch(:server)
role :db, fetch(:server), :primary => true

namespace :deploy do

  # Prompt to make really sure we want to deploy into production
  # By http://www.pastbedti.me/2009/01/handling-a-staging-environment-with-capistrano-rails/
  desc "Confirm if the deployment should proceed"
  task :confirm do
    puts "\n\e[0;31m"
    puts "   ######################################################################"
    puts "          Are you REALLY sure you want to deploy to #{stage.upcase} ?"
    puts "           Enter [y/Y] to continue or anything else to cancel"
    puts "   ######################################################################"
    puts "\e[0m\n"
    if fetch(:auto_accept) == 0
      proceed = STDIN.gets[0..0] rescue nil
      unless proceed == 'y' || proceed == 'Y'
        puts "Aborting..."
        exit
      end
    end
  end

end
