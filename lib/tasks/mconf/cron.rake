namespace :mconf do
  namespace :cron do
    desc "Mconf daily tasks"
    task :daily  => [ "mconf:analytics:update" ]

    desc "Mconf weekly tasks"
    task :weekly  => [ "mconf:analytics:init" ]
  end
end
