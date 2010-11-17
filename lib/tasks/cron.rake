namespace :cron do
  desc "Hourly tasks"
  task :hourly => [ "station:sources:import" ]
  task :daily  => [ "station:openid:gc_ar_store", "marte:cleanrooms", "vcc:update_statistics" ]
end
