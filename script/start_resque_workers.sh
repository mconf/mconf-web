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
#   start_resque_workers.sh start all

USER="$(id -u -n)"
APP_PATH="$(dirname $0)/.."
PATH=/home/$USER/.rbenv/bin:/home/$USER/.rbenv/shims:$PATH
RAILS_ENV=production

if [ "$2" == "all" ]; then
  PIDFILE=$APP_PATH/tmp/pids/resque_workers_all.pid
  LOGFILE=$APP_PATH/log/resque_workers_all.log
else
  PIDFILE=$APP_PATH/tmp/pids/resque_workers_$2.pid
  LOGFILE=$APP_PATH/log/resque_workers_$2.log
fi

cd $APP_PATH

if [ "$1" != "stop" ]; then
  if [ "$2" == "all" ]; then
    /usr/bin/env bundle exec rake environment resque:workers RAILS_ENV=$RAILS_ENV PIDFILE=$PIDFILE VERBOSE=1 QUEUE="*" COUNT="3" >> $LOGFILE 2>&1
  else
    /usr/bin/env bundle exec rake environment resque:workers RAILS_ENV=$RAILS_ENV PIDFILE=$PIDFILE VERBOSE=1 QUEUE=$2 COUNT="3" >> $LOGFILE 2>&1
  fi
else
  kill -9 $(cat $PIDFILE) && rm -f $PIDFILE; exit 0;
fi
