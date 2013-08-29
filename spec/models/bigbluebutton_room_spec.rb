# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe BigbluebuttonRoom do

  # This is a model from BigbluebuttonRails, but we have a few custom abilities set for
  # it that we test here, as simplified as possible.
  describe "abilities" do
    set_custom_ability_actions([:create_meeting])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:user) { FactoryGirl.create(:user) }

    context "a user in his own room" do
      it { should be_able_to(:create_meeting, user.bigbluebutton_room) }
    end

    context "a user in his another user's room" do
      let(:another_user) { FactoryGirl.create(:user) }
      it { should_not be_able_to(:create_meeting, another_user.bigbluebutton_room) }
    end

    context "a user in a space" do
      let(:space) { FactoryGirl.create(:space) }

      context "he doesn't belong to" do
        it { should_not be_able_to(:create_meeting, space.bigbluebutton_room) }
      end

      context "he belongs to" do
        before { space.add_member!(user) }
        it { should be_able_to(:create_meeting, space.bigbluebutton_room) }
      end
    end
  end

end
