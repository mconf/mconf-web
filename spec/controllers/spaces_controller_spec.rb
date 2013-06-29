# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SpacesController do

  render_views

  describe "#index" do
    it "sets param[:view] to 'list' if not set"
    it "sets param[:view] to 'list' if different than 'thumbnails'"
    it "uses param[:view] as 'thumbanils' if already set to this value"
  end

end
