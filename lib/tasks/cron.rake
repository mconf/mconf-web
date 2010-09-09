namespace :cron do
  desc "Hourly tasks"
  task :hourly => [ "station:sources:import", "chat_logs:save" ]
  task :daily  => [ "station:openid:gc_ar_store", "marte:cleanrooms" ]
end
