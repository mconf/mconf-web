# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Attachment do

  describe "abilities" do
    subject { ability }
    let(:ability) { Ability.new(user) }
    let(:target) { FactoryGirl.create(:attachment) }

    context "when is the attachment author" do
      let(:user) { target.author }
      it { should_not be_able_to_do_anything_to(target).except([:read, :destroy]) }

      context "but the space has the file repository disabled" do
        before {
          target.space.add_member!(user)
          target.space.update_attributes(:repository => false)
        }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is an anonymous user" do
      let(:user) { User.new }

      context "and the attachment is in a public space" do
        before { target.space.update_attributes(:public => true) }
        it { should_not be_able_to_do_anything_to(target).except(:read) }
      end

      context "and the attachment is in a private space" do
        before { target.space.update_attributes(:public => false) }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is a registered user" do
      let(:user) { FactoryGirl.create(:user) }

      context "that's a member of the space the attachment is in" do
        let(:user) { FactoryGirl.create(:user) }
        before { target.space.add_member!(user) }
        it { should_not be_able_to_do_anything_to(target).except([:read, :create]) }
      end

      context "that's not a member of the private space the attachment is in" do
        let(:user) { FactoryGirl.create(:user) }
        before { target.space.update_attributes(:public => false) }
        it { should_not be_able_to_do_anything_to(target) }
      end

      context "that's not a member of the public space the attachment is in" do
        let(:user) { FactoryGirl.create(:user) }
        before { target.space.update_attributes(:public => true) }
        it { should_not be_able_to_do_anything_to(target).except(:read) }
      end

      context "member of the space but the space has the file repository disabled" do
        let(:user) { FactoryGirl.create(:user) }
        before {
          target.space.add_member!(user)
          target.space.update_attributes(:repository => false)
        }
        it { should_not be_able_to_do_anything_to(target) }
      end
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      it { should be_able_to(:manage, target) }
    end

  end
end
