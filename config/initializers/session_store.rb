# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Be sure to restart your server when you modify this file.

Mconf::Application.config.session_store :cookie_store, key: '_mconf_session', expire_after: 60.minutes

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
# Mconf::Application.config.session_store :active_record_store
