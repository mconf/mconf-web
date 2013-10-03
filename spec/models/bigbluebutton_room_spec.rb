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
    set_custom_ability_actions([:end, :join_options, :create_meeting, :fetch_recordings,
                                :invite, :invite_userid, :auth, :running, :join, :external,
                                :external_auth, :join_mobile])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:user) { FactoryGirl.create(:user) }

    context "a user in his own room" do
      let(:target) { user.bigbluebutton_room }
      let(:allowed) { [:end, :join_options, :create_meeting, :fetch_recordings,
                       :invite, :invite_userid, :auth, :running, :join, :external,
                       :external_auth, :join_mobile] }
      it { should_not be_able_to_do_anything_to(target).except(allowed) }
    end

    context "a user in his another user's room" do
      let(:another_user) { FactoryGirl.create(:user) }
      let(:target) { another_user.bigbluebutton_room }
      let(:allowed) { [:invite, :invite_userid, :auth, :running, :join, :external,
                       :external_auth, :join_mobile] }
      it { should_not be_able_to_do_anything_to(target).except(allowed) }
    end

    context "a user in a space" do
      let(:space) { FactoryGirl.create(:space) }
      let(:target) { space.bigbluebutton_room }

      context "he doesn't belong to" do
        let(:allowed) { [:invite, :invite_userid, :auth, :running, :join, :external,
                         :external_auth, :join_mobile] }
        it { should_not be_able_to_do_anything_to(target).except(allowed) }
      end

      context "he belongs to" do
        before { space.add_member!(user) }
        let(:allowed) { [:end, :join_options, :create_meeting, :fetch_recordings,
                         :invite, :invite_userid, :auth, :running, :join, :external,
                         :external_auth, :join_mobile] }
        it { should_not be_able_to_do_anything_to(target).except(allowed) }
      end
    end
  end

end
