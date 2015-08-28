# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

Rails.application.config.to_prepare do

  Leaflet.tile_layer = "http://b.tile.openstreetmap.org/{z}/{x}/{y}.png"
  Leaflet.attribution = " \u00A9 OpenStreetMap contrib. <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA 2.0</a>"
  Leaflet.max_zoom = 15

  module MwebEvents
    SOCIAL_NETWORKS = ['Facebook', 'Google Plus', 'Twitter', 'Linkedin']
  end

  # if defined?(MwebEvents)
    configatron.modules.events.loaded = true
  # end

  if configatron.modules.events.loaded
    # Monkey patching events controller for pagination and recent activity
    # load './lib/mweb_events/controllers/events_controller.rb'
    # load './lib/mweb_events/models/event.rb'

    # Same for participants, public activity is still missing
    # load './lib/mweb_events/controllers/participants_controller.rb'
    # load './lib/mweb_events/models/participant.rb'
  end

end
