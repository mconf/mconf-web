# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class EventInvitation < Invitation

  # Ensure invitations will never be found if events are disabled
  default_scope -> {
    EventInvitation.none unless Mconf::Modules.mod_enabled?('events')
  }

end
