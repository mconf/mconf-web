# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron
# Learn more: http://github.com/javan/whenever

# for some reason the default 'rake' wasn't using 'bundle exec', so we're redefining it here
job_type :rake, "cd :path && RAILS_ENV=:environment bundle exec rake :task --silent :output"

every :day, :at => '1am' do
  # updates the stats - will only increment stats from the past day
  rake "mconf:statistics:update"
end

every :sunday, :at => '2am' do
  # restart the analytics stats every week
  rake "mconf:statistics:init"
end

every :day, :at => '2pm' do
  # send daily digest emails
  runner "Mconf::DigestEmail.send_daily_digest"
end

every :monday, :at => '2pm' do
  # send weekly digest emails
  runner "Mconf::DigestEmail.send_weekly_digest"
end
