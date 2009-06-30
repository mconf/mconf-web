namespace :cron do
  desc "Hourly tasks"
  task :hourly => [ "station:sources:import" ]
end
