# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
# Learn more: http://github.com/javan/whenever

# for some reason the default 'rake' wasn't using 'bundle exec', so we're redefining it here
job_type :rake, "cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"

every 1.day, :at => '2am' do
  rake "mconf:analytics:update"
end

every :sunday, :at => '3am' do
  rake "mconf:analytics:init"
end
