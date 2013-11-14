#!/usr/bin/env bash

# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2013 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Wrapper script to run resque from monit
# Arguments:
#   $1: (start|stop)
#   $2: queue name, e.g. 'bigbluebutton_rails'
# Example:
#   start_resque_workers.sh start bigbluebutton_rails

USER="$(id -u -n)"
APP_PATH="$(dirname $0)/.."
PATH=/home/$USER/.rbenv/bin:/home/$USER/.rbenv/shims:$PATH
RAILS_ENV=production
PIDFILE=$APP_PATH/tmp/pids/resque_worker_$2.pid
LOGFILE=$APP_PATH/log/resque_worker_$2.log

cd $APP_PATH

if [ "$1" != "stop" ]; then
  /usr/bin/env bundle exec rake environment resque:work RAILS_ENV=$RAILS_ENV PIDFILE=$PIDFILE BACKGROUND=yes QUEUE=$2 >> $LOGFILE 2>&1
else
  kill -9 $(cat $PIDFILE) && rm -f $PIDFILE; exit 0;
fi
