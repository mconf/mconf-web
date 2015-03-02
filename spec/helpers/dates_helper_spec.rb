# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

include Devise::TestHelpers

describe DatesHelper do
  describe "#formatted_time_ago" do
    it "uses a <span> tag"
    it "uses the correct text"
    it "uses the correct title"
    it "uses the options passed on the arguments"
    it "uses the options for time_ago_in_words passed on the arguments"
  end

  describe "#format_date" do
    it "returns the date formatted to show in a view"
    it "returns a localized string"
  end
end
