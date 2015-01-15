require 'spec_helper'

describe ParticipantConfirmation do
  let(:email) { 'sympho@nyxrul.es' }

  it { should belong_to(:participant).dependent(:destroy).class_name("MwebEvents::Participant") }
  it { should delegate_method(:email).to(:participant) }

  describe '#generate_token' do
    let(:participant) { FactoryGirl.create(:participant, email: email) }
    let(:pc) { ParticipantConfirmation.new(participant: participant) }

    it { pc.token.should be(nil) }

    context "after being created" do
      before { pc.save! }

      it { pc.token.should_not be(nil) }
      it { pc.token.size.should be(22) }
    end
  end

  skip '#send_participant_confirmation'

  describe '#confirm!' do
    let(:participant) { FactoryGirl.create(:participant, email: email) }
    let(:pc) { participant.participant_confirmation }

    it { pc.should_not be_confirmed }

    context 'after confirm!' do
      before { pc.confirm! }
      it { pc.should be_confirmed }
    end
  end
end