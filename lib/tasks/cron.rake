namespace :cron do
  desc "Hourly tasks"
  task :daily => [ "vcc:update_statistics"]
  task :hourly => [ "station:sources:import" ]
  task :daily  => [ "station:openid:gc_ar_store", "marte:cleanrooms" ]
end
