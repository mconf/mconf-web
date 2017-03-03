# coding: utf-8
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Defaults for redis
configatron.redis.host = ENV['MCONF_REDIS_HOST'] || 'localhost'
configatron.redis.port = ENV['MCONF_REDIS_PORT'] || 6379
configatron.redis.db = ENV['MCONF_REDIS_DB'] || 0

# Translations for the languages available. The names of the languages are not
# translated, so it's better to have them here than in the locale files.
# See `config.i18n.available_locales` in `config/application.rb`
configatron.locales.names =
  {
    bg: "Български",
    de: "Deutsch",
    en: "English",
    "es-419": "Español",
    "pt-br": "Português",
    ru: "Pусский"
  }

# Scope for all URLs related to conferences
configatron.conf.scope = ENV['MCONF_CONFERENCE_SCOPE'] || 'conf'
# Scope for the short URLs of web conference rooms
configatron.conf.scope_rooms = ENV['MCONF_CONFERENCE_SCOPE_ROOMS'] || 'conf'
