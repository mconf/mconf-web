# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

Rails.application.config.to_prepare do

  if defined?(MwebEvents)
    configatron.modules.events.loaded = true
  end

  if configatron.modules.events.loaded
    # Monkey patching events controller for pagination and recent activity
    load './lib/mweb_events/controllers/events_controller.rb'
    load './lib/mweb_events/models/event.rb'

    # Same for participants, public activity is still missing
    load './lib/mweb_events/controllers/participants_controller.rb'
    load './lib/mweb_events/models/participant.rb'
  end

end
