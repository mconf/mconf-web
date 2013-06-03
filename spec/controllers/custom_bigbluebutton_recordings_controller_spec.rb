# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonRecordingsController do
  render_views

  pending "requires authentication"
  pending "routes accessible only to admins"
  pending "for recordings of users' rooms, #play is accessible to the owner only"
  pending "for recordings of spaces' rooms, #play is accessible to anyone that belongs to the space"
  pending "uses the layout 'application' for all routes"
end
