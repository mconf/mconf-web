# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe ParticipantConfirmationsSenderWorker do
  let(:worker) { ParticipantConfirmationsSenderWorker }

  it "uses the queue :participant_confirmations" do
    worker.instance_variable_get(:@queue).should eql(:participant_confirmations)
  end

  describe "#perform" do
    let(:pc1) { FactoryGirl.create(:participant, email: 'abc@def.cam', owner: nil).participant_confirmation }
    let(:pc2) { FactoryGirl.create(:participant, email: 'def@abc.com', owner: nil).participant_confirmation }
    before(:each) {
      pc2.update_attribute(:email_sent_at, Time.now)
      worker.perform(pc1.id)
      worker.perform(pc2.id)
    }

    it { ParticipantConfirmationMailer.should have_queue_size_of(1) }
    it { ParticipantConfirmationMailer.should have_queued(:confirmation_email, pc1.id).in(:mailer) }
    it { ParticipantConfirmationMailer.should_not have_queued(:confirmation_email, pc2.id).in(:mailer) }
    it { pc1.reload.email_sent_at.should_not be_nil }
    it { pc2.reload.email_sent_at.should_not be_nil }
  end

  # might happen if an admin removes a participant before the notification is sent
  it "doesn't break if a ParticipantConfirmation has no participant associated"
end
