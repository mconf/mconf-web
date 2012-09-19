# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe News do

  describe "abilities" do
    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:target) { FactoryGirl.create(:news) }

    context "when is an anonymous user" do
      let(:user) { User.new }

      context "and the news is in a public space" do
        before { target.space.update_attributes(:public => true) }
        it { should_not be_able_to_do_anything_to(target).except(:read) }
      end

      context "and the news is in a private space" do
        before { target.space.update_attributes(:public => false) }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "trying to create a news" do
        let(:space) { FactoryGirl.create(:space) }
        it { should_not be_able_to(:create, space.posts.build) }
      end
    end

    context "when is a registered user" do
      context "that's a member of the space the news is in" do
        let(:user) { FactoryGirl.create(:user) }
        before { target.space.add_member!(user) }
        it { should_not be_able_to_do_anything_to(target).except(:read) }
      end

      context "that's not a member of the private space the news is in" do
        let(:user) { FactoryGirl.create(:user) }
        before { target.space.update_attributes(:public => false) }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "that's not a member of the public space the news is in" do
        let(:user) { FactoryGirl.create(:user) }
        before { target.space.update_attributes(:public => true) }
        it { should_not be_able_to_do_anything_to(target).except(:read) }
      end
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      it { should be_able_to(:manage, target) }
    end

  end
end
