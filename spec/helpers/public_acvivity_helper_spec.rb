# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe PublicActivitiesHelper do

  describe "#activity_translate" do
    it "returns a default translated string based on the parameters"
  end

  describe "#link_to_trackable" do
    context "if trackable is nil" do
      it "returns a default translated string"
    end
    it "returns the correct link for spaces"
    it "returns the correct link for events"
    it "returns the correct link for posts"
    it "returns the correct link for news"
    it "returns the correct link for attachments"
    it "returns the correct link for bigbluebutton meetings"
  end

end
