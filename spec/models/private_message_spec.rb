# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe PrivateMessage do

  describe "abilities", :abilities => true do
    subject { ability }
    let(:ability) { Abilities.ability_for(user) }
    let(:target) { FactoryGirl.create(:private_message) }

    context "when is a registered user" do
      context "and the message sender" do
        let(:user) { target.sender }
        it { should_not be_able_to_do_anything_to(target).except([:read, :destroy, :create]) }
      end

      context "and the message receiver" do
        let(:user) { target.receiver }
        it { should_not be_able_to_do_anything_to(target).except([:read, :create, :destroy]) }
      end

      context "but not the sender or receiver" do
        let(:user) { FactoryGirl.create(:user) }
        it { should_not be_able_to_do_anything_to(target).except(:create) }
      end
    end

    context "when is an anonymous user" do
      let(:user) { User.new }
      it { should_not be_able_to_do_anything_to(target) }
    end

    context "when is a superuser" do
      let(:user) { FactoryGirl.create(:superuser) }
      it { should be_able_to(:manage, target) }
    end

  end
end
