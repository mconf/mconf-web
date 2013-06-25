# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ApplicationController do

  describe "#set_time_zone" do

    # TODO: not sure if tested here or in every action in every controller (sounds bad)
    it "is called before every action"

    it "uses the user timezone if specified"
    it "uses the site timezone if the user's timezone is not specified"
    it "uses UTC if everything fails"
    it "ignores the user if there's no current user"
    it "ignores the user if the user is not an instance of User"
    it "ignores the user if his timezone is not defined"
    it "ignores the user if his timezone is an empty string"
    it "ignores the site if there's no current site"
    it "ignores the site if its timezone is not defined"
    it "ignores the site if its timezone is an empty string"
  end

  describe "#bigbluebutton_role" do
    context "for user rooms" do
      it "if the user is disabled returns nil"
      context "if the room is private" do
        it "if the user is the owner returns :moderator"
        it "if the user is not the owner returns :password"
        it "if there's no user logged returns :password"
      end
      context "if the room is public" do
        it "if the user is the owner returns :moderator"
        it "if the user is not the owner returns :guest"
        it "if there's no user logged returns :guest"
      end
    end
    context "for space rooms" do
      it "if the space is disabled returns nil"
      context "if the room is private" do
        it "if the user is a member of the space returns :moderator"
        it "if the user is not a member of the space :password"
      end
      context "if the room is public" do
        it "if the user is a member of the space returns :moderator"
        it "if the user is not a member of the space :guest"
      end
    end
  end

  describe "#bigbluebutton_user" do
    it "if current_user is defined and is an instance of User, returns it"
    it "if current_user is not defined returns nil"
    it "if current_user is not an instance of User returns nil"
  end

end
