# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe CustomBigbluebuttonServersController do
  render_views

  pending "requires authentication for all routes"
  pending "verify authorization" # break down, it's too generic
  pending "uses the layout 'application' for all routes"
  describe "#sort_meetings" do
    pending "sort meetings by name alphabetically"
  end

  # TODO: break down for every action and test the layout and view rendered
end
