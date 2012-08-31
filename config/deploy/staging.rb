# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

#
# Include here any configuration specific the stage: STAGING
#

# Load values from the config file
configs[stage.to_s].each do |hash_key, hash_value|
  set(hash_key.to_sym, hash_value.to_s)
end
unless configs[stage.to_s].has_key?("deploy_to")
  set :deploy_to, "/home/#{fetch(:user)}/#{fetch(:application)}"
end

role :app, fetch(:server)
role :web, fetch(:server)
role :db, fetch(:server), :primary => true
