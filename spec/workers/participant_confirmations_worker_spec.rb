# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe ParticipantConfirmationsWorker, type: :worker do
  let(:worker) { ParticipantConfirmationsWorker }
  let(:queue) { Queue::High }
  let(:params) {{"method"=>:confirmation_sender, "class"=>ParticipantConfirmationsWorker.to_s}}

  describe "#perform" do
    before { ParticipantConfirmation.delete_all }

    context "enqueues all unnotified participant confirmations" do
      let!(:pc1) { FactoryGirl.create(:participant_confirmation) }
      let!(:pc2) { FactoryGirl.create(:participant_confirmation, email_sent_at: Time.now) }
      let!(:pc3) { FactoryGirl.create(:participant_confirmation) }
      let!(:pc4) { FactoryGirl.create(:participant_confirmation, email_sent_at: Time.now) }

      before(:each) { worker.perform }
      it { expect(queue).to have_queue_size_of(2) }
      it { expect(queue).to have_queued(params, pc1.id) }
      it { expect(queue).to have_queued(params, pc3.id) }
      it { expect(queue).not_to have_queued(params, pc2.id) }
      it { expect(queue).not_to have_queued(params, pc4.id) }
    end
  end

  describe "#confirmation_sender" do
    let(:pc1) { FactoryGirl.create(:participant, email: 'abc@def.cam', owner: nil).participant_confirmation }
    let(:pc2) { FactoryGirl.create(:participant, email: 'def@abc.com', owner: nil).participant_confirmation }
    before(:each) {
      pc2.update_attribute(:email_sent_at, Time.now)
      worker.confirmation_sender(pc1.id)
      worker.confirmation_sender(pc2.id)
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
