#!/usr/bin/env bash

# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2013 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Wrapper script to run delayed_job from monit

USER="$(id -u -n)"
APP_PATH="$(pwd)/.."
PATH=/home/$USER/.rbenv/bin:/home/$USER/.rbenv/shims:$PATH
RAILS_ENV=production

cd $APP_PATH
/usr/bin/env RAILS_ENV=$RAILS_ENV bundle exec script/delayed_job --pid-dir=$APP_PATH/tmp/pids $1
