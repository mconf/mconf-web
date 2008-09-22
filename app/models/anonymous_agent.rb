require 'vendor/plugins/cmsplugin/app/models/anonymous_agent.rb'

class AnonymousAgent
  def superuser
    false
  end

  def login
    "Anonymous"
  end
end
