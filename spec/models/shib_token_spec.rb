# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ShibToken do

  it { should belong_to(:user) }

  it { should validate_presence_of(:identifier) }
  it { should validate_uniqueness_of(:identifier) }

  it { should validate_presence_of(:user_id) }
  it { should validate_uniqueness_of(:user_id) }

  it "serializes 'data'"

  describe "#user_with_disabled" do
    let(:user) { FactoryGirl.create(:user) }
    let(:target) { FactoryGirl.create(:shib_token, user: user) }

    context "when the user is not disabled" do
      it { target.user_with_disabled.should eql(user) }
      it { target.reload.user.should_not eql(nil) }
      it { target.user.disabled?.should be false }
    end

    context "when the user is disabled" do
      before { user.disable }
      it { target.user_with_disabled.should eql(user) }
      it { target.reload.user.should eql(nil) }
      it { target.user.disabled?.should be true }
    end
  end

  describe "#user_created_by_shib?" do
    let(:user) { FactoryGirl.create(:user) }

    context "when the user has no token" do
      it { ShibToken.user_created_by_shib?(user).should be(false) }
    end

    context "when the user has a token associated with an existing account" do
      before {
        FactoryGirl.create(:shib_token, user: user, new_account: false)
      }
      it { ShibToken.user_created_by_shib?(user).should be(false) }
    end

    context "when another user has a token created by shib" do
      let(:another_user) { FactoryGirl.create(:user) }
      before {
        FactoryGirl.create(:shib_token, user: user, new_account: false)
        FactoryGirl.create(:shib_token, user: another_user, new_account: true)
      }
      it { ShibToken.user_created_by_shib?(user).should be(false) }
    end

    context "when the user has an account created by shib" do
      before {
        FactoryGirl.create(:shib_token, user: user, new_account: true)
      }
      it { ShibToken.user_created_by_shib?(user).should be(true) }
    end
  end

  describe "#last_sign_in_date" do
    it "returns the last sign in date"
    it "returns the same as #current_sign_in_at"
  end

  describe "abilities", :abilities => true do
    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:target) { FactoryGirl.create(:shib_token) }

    context "a superuser", :user => "superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      it { should be_able_to_do_everything_to(target) }
    end

    context "a normal user", :user => "normal" do
      let(:user) { FactoryGirl.create(:user) }
      it { should_not be_able_to_do_anything_to(target) }
    end

    context "an anonymous user", :user => "anonymous" do
      let(:user) { User.new }
      it { should_not be_able_to_do_anything_to(target) }
    end
  end
end
