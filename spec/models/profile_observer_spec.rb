# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ProfileObserver do

  context "after_update" do
    let(:user) { FactoryGirl.create(:user) }
    let(:profile) { Profile.create(:user => user) }

    context "updates the name of the user's web conference room" do
      before(:each) {
        profile.user.bigbluebutton_room.update_attribute(:name, "name before")
        profile.update_attributes(:full_name => "name after") # trigger the observer
      }
      it { profile.user.bigbluebutton_room.name.should eq("name after") }
    end
  end

end
