# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Post do

  describe "abilities", :abilities => true do
    set_custom_ability_actions([:reply_post])

    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:target) { FactoryGirl.create(:post) }

    context "when is the post author" do
      let(:user) { target.author }
      it { should_not be_able_to_do_anything_to(target).except([:read, :reply_post, :edit, :update, :destroy]) }

      context "and the target space is disabled" do
        before { target.space.disable }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is an anonymous user" do
      let(:user) { User.new }

      context "and the post is in a public space" do
        before { target.space.update_attributes(:public => true) }
        it { should_not be_able_to_do_anything_to(target).except(:read) }
      end

      context "and the post is in a private space" do
        before { target.space.update_attributes(:public => false) }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "and the target space is disabled" do
        before { target.space.disable }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is a registered user" do
      let(:user) { FactoryGirl.create(:user) }

      context "that's a member of the space the post is in" do
        before { target.space.add_member!(user) }
        it { should_not be_able_to_do_anything_to(target).except([:read, :create, :reply_post]) }
      end

      context "that's not a member of the private space the post is in" do
        before { target.space.update_attributes(:public => false) }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "that's not a member of the public space the post is in" do
        before { target.space.update_attributes(:public => true) }
        it { should_not be_able_to_do_anything_to(target).except(:read) }
      end

      context "and the target space is disabled" do
        before { target.space.disable }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      it { should be_able_to_do_everything_to(target) }

      context "and the target space is disabled" do
        before { target.space.disable }
        it { should be_able_to_do_everything_to(target) }
      end
    end

  end
end
