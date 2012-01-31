# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
# Learn more: http://github.com/javan/whenever

# for some reason the default 'rake' wasn't using 'bundle exec', so we're redefining it here
job_type :rake, "cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"

every :day, :at => '2am' do
  # updates the stats - will only increment stats from the past day
  rake "mconf:analytics:update"
  # send daily emails
  runner "Mconf::DigestEmail.send_daily_digest"
end

every :sunday, :at => '3am' do
  # restart the analytics stats every week
  rake "mconf:analytics:init"
  # send weekly emails
  runner "Mconf::DigestEmail.send_weekly_digest"
end
