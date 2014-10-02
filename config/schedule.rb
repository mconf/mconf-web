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

set :output, 'log/whenever.log'

# job types copied from whenever but setting what we need to run them using rbenv
job_type :rbenv_rake, "export PATH=$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH; eval \"$(rbenv init -)\"; cd :path && RAILS_ENV=:environment bundle exec rake :task :output"
job_type :rbenv_runner,  "export PATH=$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH; eval \"$(rbenv init -)\"; cd :path && script/rails runner -e :environment ':task' :output"

every :day, :at => '2pm' do
  # send daily digest emails
  rbenv_runner "Mconf::DigestEmail.send_daily_digest"
end

every :monday, :at => '2pm' do
  # send weekly digest emails
  rbenv_runner "Mconf::DigestEmail.send_weekly_digest"
end
