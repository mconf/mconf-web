# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe InvitationsWorker, type: :worker do
  let(:worker) { InvitationsWorker }
  let(:queue) { Queue::High }
  let(:params) { { "method" => :invitation_sender, "class" => worker.to_s } }

  describe "#perform" do

    describe "queues unsent invitations for web conferences and events in the specified queue" do
      let!(:invitation_conference) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true) }
      let!(:invitation_event) { FactoryGirl.create(:event_invitation, :sent => false, :ready => true) }

      before(:each) { worker.perform }

      it { expect(queue).to have_queue_size_of(2) }
      it { expect(queue).to have_queued(params, invitation_conference.id) }
      it { expect(queue).to have_queued(params, invitation_event.id) }
    end

    describe "doesn't queue unready invitations in the specified queue" do
      let!(:invitation_ready) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true) }
      let!(:invitation_not_ready) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => false) }

      before(:each) { worker.perform }

      it { expect(queue).to have_queue_size_of(1) }
      it { expect(queue).to have_queued(params, invitation_ready.id) }
      it { expect(queue).not_to have_queued(params, invitation_not_ready.id) }
    end

    describe "doesn't queue already sent invitations in the specified queue" do
      let!(:invitation_sent) { FactoryGirl.create(:web_conference_invitation, :sent => true, :ready => true) }
      let!(:invitation_not_sent) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true) }

      before(:each) { worker.perform }

      it { expect(queue).to have_queue_size_of(1) }
      it { expect(queue).to have_queued(params, invitation_not_sent.id) }
      it { expect(queue).not_to have_queued(params, invitation_sent.id) }
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

  describe "#invitation_sender" do

    context "sends the invitation and marks as sent" do
      let!(:invitation) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true, :result => false) }
      before { Invitation.any_instance.should_receive(:send_invitation) { true } }
      before(:each) { worker.invitation_sender(invitation.id) }
      it { invitation.reload.sent.should be(true) }
    end

    context "doesnt send the invitation if it's already marked as sent" do
      let!(:invitation) { FactoryGirl.create(:web_conference_invitation, :sent => true, :ready => true, :result => false) }
      before { Invitation.any_instance.should_not_receive(:send_invitation) }
      before(:each) { worker.invitation_sender(invitation.id) }

      it { invitation.reload.sent.should be(true) }
    end

    context "saves in the invitation the return if Invitation#send_invitation" do
      let!(:invitation) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true, :result => false) }

      context "when it returns false" do
        before { Invitation.any_instance.should_receive(:send_invitation) { false } }
        before(:each) { worker.invitation_sender(invitation.id) }
        it { invitation.reload.result.should be(false) }
      end

      context "when it returns true" do
        before { Invitation.any_instance.should_receive(:send_invitation) { true } }
        before(:each) { worker.invitation_sender(invitation.id) }
        it { invitation.reload.result.should be(true) }
      end
    end

  end


end
