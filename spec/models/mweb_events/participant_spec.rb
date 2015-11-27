# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Participant do

  it { should validate_presence_of(:event_id) }
  it { should validate_presence_of(:email) }
  it { should validate_uniqueness_of(:email).scoped_to(:event_id) }
  it { should validate_uniqueness_of(:owner_id).scoped_to(:event_id) }

  it { should belong_to(:event) }
  it { should belong_to(:owner) }

  it { should respond_to(:email) }
  it { should respond_to(:email=) }
  it { should respond_to(:event) }
  it { should respond_to(:event=) }
  it { should respond_to(:event_id) }
  it { should respond_to(:event_id=) }

  it "creates a new instance given valid attributes" do
    FactoryGirl.build(:participant).should be_valid
  end

  it "does NOT create a new instance given invalid email address" do
    FactoryGirl.build(:participant, :email => 'booboo').should_not be_valid
  end

  describe ".email_taken?" do
    let(:participant) { FactoryGirl.create(:participant) }

    context "when it is the same event and same email" do
      let(:late_participant) { FactoryGirl.build(:participant, :email => participant.email, :event => participant.event) }
      it { late_participant.email_taken?.should be(true) }
    end

    context "when it is the same event but different email" do
      let(:late_participant) { FactoryGirl.build(:participant, :event => participant.event) }
      it { late_participant.email_taken?.should be_falsey }
    end

    context "when it is not same event but the same email" do
      let(:late_participant) { FactoryGirl.build(:participant, :email => participant.email) }
      it { late_participant.email_taken?.should be_falsey }
    end

    context "when it is not same event and not the same email" do
      let(:late_participant) { FactoryGirl.build(:participant, :email => participant.email) }
      it { late_participant.email_taken?.should be_falsey }
    end
  end

  skip "abilities (using permissions, space admins, event organizers)"
  skip "activities"

  it { should have_one(:participant_confirmation) }

  context '#create_participant_confirmation if annonymous?' do
    it { expect{
        FactoryGirl.create(:participant, owner: nil)
      }.to change{ParticipantConfirmation.count}.by(1)
    }
  end

  context '#annonymous?' do
    it { FactoryGirl.build(:participant, owner: nil).should be_annonymous }
  end

  context '#email_confirmed?' do
    it { FactoryGirl.create(:participant, owner: FactoryGirl.create(:user)).should be_email_confirmed }
    it { FactoryGirl.create(:participant, owner: nil).should_not be_email_confirmed }
  end
end
