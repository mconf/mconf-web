# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module EventsHelper

  def will_user_participate?(event, user)
    event.participants.select { |p| p.user == user }.first.attend
  end

  def get_participant(event, user)
    event.participants.select { |p| p.user == user }.first
  end

end
