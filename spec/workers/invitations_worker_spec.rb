# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe InvitationsWorker do
  let(:worker) { InvitationsWorker }

  it "uses the queue :join_requests" do
    worker.instance_variable_get(:@queue).should eql(:invitations)
  end

  describe "#perform" do

    describe "queues unsent invitations for web conferences and events" do
      let!(:invitation_conference) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true) }
      let!(:invitation_event) { FactoryGirl.create(:event_invitation, :sent => false, :ready => true) }

      before(:each) { worker.perform }

      it { expect(InvitationSenderWorker).to have_queue_size_of(2) }
      it { expect(InvitationSenderWorker).to have_queued(invitation_conference.id) }
      it { expect(InvitationSenderWorker).to have_queued(invitation_event.id) }
    end

    describe "doesn't queue unready invitations" do
      let!(:invitation_ready) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true) }
      let!(:invitation_not_ready) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => false) }

      before(:each) { worker.perform }

      it { expect(InvitationSenderWorker).to have_queue_size_of(1) }
      it { expect(InvitationSenderWorker).to have_queued(invitation_ready.id) }
      it { expect(InvitationSenderWorker).not_to have_queued(invitation_not_ready.id) }
    end

    describe "doesn't queue already sent invitations" do
      let!(:invitation_sent) { FactoryGirl.create(:web_conference_invitation, :sent => true, :ready => true) }
      let!(:invitation_not_sent) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true) }

      before(:each) { worker.perform }

      it { expect(InvitationSenderWorker).to have_queue_size_of(1) }
      it { expect(InvitationSenderWorker).to have_queued(invitation_not_sent.id) }
      it { expect(InvitationSenderWorker).not_to have_queued(invitation_sent.id) }
    end

    # describe "saves in the invitation the return if Invitation#send_invitation" do
    #   let(:invitation) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true, :result => false) }

    #   before do
    #     ResqueSpec.reset!
    #     invitation
    #     Invitation.any_instance.should_receive(:send_invitation) { false }
    #     worker.perform
    #   end

    #   it { invitation.result.should be_falsey }
    # end

  end
end
