# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ApplicationController do

  describe "#set_time_zone" do

    # TODO: not sure if tested here or in every action in every controller (sounds bad)
    pending "is called before every action"

    pending "uses the user timezone if specified"
    pending "uses the site timezone if the user's timezone is not specified"
    pending "uses UTC if everything fails"
    pending "ignores the user if there's no current user"
    pending "ignores the user if the user is not an instance of User"
    pending "ignores the user if his timezone is not defined"
    pending "ignores the user if his timezone is an empty string"
    pending "ignores the site if there's no current site"
    pending "ignores the site if its timezone is not defined"
    pending "ignores the site if its timezone is an empty string"
  end

end
