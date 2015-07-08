# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe ParticipantConfirmationsWorker do
  let(:worker) { ParticipantConfirmationsWorker }

  it "uses the queue :participant_confirmations" do
    worker.instance_variable_get(:@queue).should eql(:participant_confirmations)
  end

  describe "#perform" do
    before { ParticipantConfirmation.delete_all }

    context "enqueues all unnotified participant confirmations" do
      let!(:pc1) { FactoryGirl.create(:participant_confirmation) }
      let!(:pc2) { FactoryGirl.create(:participant_confirmation, email_sent_at: Time.now) }
      let!(:pc3) { FactoryGirl.create(:participant_confirmation) }
      let!(:pc4) { FactoryGirl.create(:participant_confirmation, email_sent_at: Time.now) }

      before(:each) { worker.perform }
      it { expect(ParticipantConfirmationsSenderWorker).to have_queue_size_of(2) }
      it { expect(ParticipantConfirmationsSenderWorker).to have_queued(pc1.id) }
      it { expect(ParticipantConfirmationsSenderWorker).to have_queued(pc3.id) }
      it { expect(ParticipantConfirmationsSenderWorker).not_to have_queued(pc2.id) }
      it { expect(ParticipantConfirmationsSenderWorker).not_to have_queued(pc4.id) }
    end

  end

end
