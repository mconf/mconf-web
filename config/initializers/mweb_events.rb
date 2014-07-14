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
