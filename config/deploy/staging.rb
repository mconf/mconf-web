#
# Include here any configuration specific the stage: STAGING
#

# Load values from the config file
configs[stage.to_s].each do |hash_key, hash_value|
  set(hash_key.to_sym, hash_value.to_s)
end

role :app, fetch(:server)
role :web, fetch(:server)
role :db, fetch(:server), :primary => true




