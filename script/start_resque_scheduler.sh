#!/usr/bin/env bash

# This file is part of Mconf-Web, a web application that provides access
# to the Mconf web conferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Wrapper script to run resque-scheduler from monit
# Arguments:
#   $1: (start|stop)
# Example:
#   start_resque_scheduler.sh start

USER="$(id -u -n)"
APP_PATH="$(dirname $0)/.."
RBENV_ROOT=${RBENV_ROOT-/home/$USER/.rbenv} # defaults to a user installation
PATH=$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH
RAILS_ENV=production
PIDFILE=$APP_PATH/tmp/pids/resque_scheduler.pid
LOGFILE=$APP_PATH/log/resque_scheduler.log

cd $APP_PATH

if [ "$1" != "stop" ]; then
  /usr/bin/env bundle exec rake environment resque:scheduler RAILS_ENV=$RAILS_ENV VERBOSE=1 PIDFILE=$PIDFILE >> $LOGFILE 2>&1 &
else
  kill -s QUIT $(cat $PIDFILE) && rm -f $PIDFILE; exit 0;
fi
