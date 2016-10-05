#!/usr/bin/env bash

# This file is part of Mconf-Web, a web application that provides access
# to the Mconf web conferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Wrapper script to run resque from monit
# Arguments:
#   $1: (start|stop)
#   $2: queue name, e.g. 'bigbluebutton_rails'
#   $3: the number of the worker, only used if $2 is "all"
# Example:
#   start_resque_workers.sh start bigbluebutton_rails
#   start_resque_workers.sh start all
#   start_resque_workers.sh start all 1

USER="$(id -u -n)"
APP_PATH="$(dirname $0)/.."
RBENV_ROOT=${RBENV_ROOT-/home/$USER/.rbenv} # defaults to a user installation
PATH=$RBENV_ROOT/bin:$RBENV_ROOT/shims:$PATH

RAILS_ENV=production
if [ -z "$3" ]; then WORKERNUM=1; else WORKERNUM=$3; fi

if [ "$2" == "all" ]; then
  PIDFILE=$APP_PATH/tmp/pids/resque_worker_$WORKERNUM.pid
  LOGFILE=$APP_PATH/log/resque_workers_all.log
else
  PIDFILE=$APP_PATH/tmp/pids/resque_worker_$2.pid
  LOGFILE=$APP_PATH/log/resque_worker_$2.log
fi

cd $APP_PATH

if [ "$1" != "stop" ]; then
  if [ "$2" == "all" ]; then
    # for all queues
    /usr/bin/env bundle exec rake environment resque:work RAILS_ENV=$RAILS_ENV PIDFILE=$PIDFILE QUEUE="mailer, high, bigbluebutton_rails, normal, low" TERM_CHILD=1 >> $LOGFILE 2>&1 &
  else
    # for specific queues
    /usr/bin/env bundle exec rake environment resque:work RAILS_ENV=$RAILS_ENV PIDFILE=$PIDFILE QUEUE=$2 TERM_CHILD=1 >> $LOGFILE 2>&1 &
  fi
else
  echo "Stopping worker pid:$(cat $PIDFILE)" >> $LOGFILE
  kill -s QUIT $(cat $PIDFILE) && rm -f $PIDFILE; exit 0;
fi
