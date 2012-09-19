# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Space do

  it "creates a new instance given valid attributes" do
    FactoryGirl.build(:space).should be_valid
  end

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:description) }
  it {
    FactoryGirl.create(:space)
    should validate_uniqueness_of(:name)
  }

  describe "abilities" do
    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:target) { FactoryGirl.create(:space) }

    context "when is an anonymous user" do
      let(:user) { User.new }

      context "and the space is public" do
        before { target.update_attributes(:public => true) }
        it { should_not be_able_to_do_anything_to(target).except(:read) }
      end

      context "and the space is private" do
        before { target.update_attributes(:public => false) }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is a registered user" do
      let(:user) { FactoryGirl.create(:user) }

      context "that's a member of the space" do
        before { target.add_member!(user) }
        it { should_not be_able_to_do_anything_to(target).except([:read, :create, :leave]) }
      end

      context "that's an admin of the space" do
        before { target.add_member!(user, "Admin") }
        it { should_not be_able_to_do_anything_to(target).except([:read, :create, :leave, :update]) }
      end

      context "that's not a member of the private space" do
        before { target.update_attributes(:public => false) }
        it { should_not be_able_to_do_anything_to(target).except(:create) }
      end

      context "that's not a member of the public space" do
        before { target.update_attributes(:public => true) }
        it { should_not be_able_to_do_anything_to(target).except([:read, :create]) }
      end
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      it { should be_able_to(:manage, target) }
    end

  end
end
