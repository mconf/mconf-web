# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SessionLocalesController do

  describe "#create" do
    it "sets the new locale in the session"
    it "sets the new locale as the default for the current user, if any"
    it "sets a success flash message using the new locale"
    it "returns an error if the locale does not exist"
  end

end
