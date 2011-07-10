#
# Include here any configuration specific the stage: STAGING
#

# Load values from the config file
configs[stage.to_s].each do |hash_key, hash_value|
  set(hash_key.to_sym, hash_value.to_s)
end
set :deploy_to, "/home/#{fetch(:user)}/#{fetch(:application)}" unless configs[stage.to_s].has_key?("deploy_to")

role :app, fetch(:server)
role :web, fetch(:server)
role :db, fetch(:server), :primary => true




