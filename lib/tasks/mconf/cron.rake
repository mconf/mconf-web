namespace :mconf do
  namespace :cron do
    desc "Mconf daily tasks"
    task :daily  => [ "mconf:analytics:update" ]
  end
end
