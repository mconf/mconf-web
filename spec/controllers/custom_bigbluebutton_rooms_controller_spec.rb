# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonRoomsController do
  render_views

  pending "requires authentication, except for #invite, #auth, #running and #external"
  pending "verify authorization" # break down, it's too generic
  pending "uses the layout 'application' except for #join_mobile"
  pending "#join_mobile uses no layout"
end
