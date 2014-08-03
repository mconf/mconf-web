# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Invitations do

  describe "#perform" do

    describe "queues unsent invitations for web conferences and events" do
      let(:invitation_conference) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true) }
      let(:invitation_event) { FactoryGirl.create(:event_invitation, :sent => false, :ready => true) }

      before do
        ResqueSpec.reset!
        invitation_conference
        invitation_event
        Invitations.perform
      end

      it { BaseMailer.should have_queue_size_of(2) }
      it { WebConferenceMailer.should have_queued(:invitation_email, invitation_conference.id).in(:mailer) }
      it { EventMailer.should have_queued(:invitation_email, invitation_event.id).in(:mailer) }
    end

    describe "doesn't queue unready invitations" do
      let(:invitation_ready) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true) }
      let(:invitation_not_ready) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => false) }

      before do
        ResqueSpec.reset!
        invitation_ready
        invitation_not_ready
        Invitations.perform
      end

      it { BaseMailer.should have_queue_size_of(1) }
      it { WebConferenceMailer.should have_queued(:invitation_email, invitation_ready.id).in(:mailer) }
      it { WebConferenceMailer.should_not have_queued(:invitation_email, invitation_not_ready.id).in(:mailer) }
    end

    describe "doesn't queue already sent invitations" do
      let(:invitation_sent) { FactoryGirl.create(:web_conference_invitation, :sent => true, :ready => true) }
      let(:invitation_not_sent) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true) }

      before do
        ResqueSpec.reset!
        invitation_sent
        invitation_not_sent
        Invitations.perform
      end

      it { BaseMailer.should have_queue_size_of(1) }
      it { WebConferenceMailer.should_not have_queued(:invitation_email, invitation_sent.id).in(:mailer) }
      it { WebConferenceMailer.should have_queued(:invitation_email, invitation_not_sent.id).in(:mailer) }
    end

    describe "saves in the invitation the return if Invitation#send_invitation" do
      let(:invitation) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true, :result => false) }

      before do
        ResqueSpec.reset!
        invitation
        Invitation.any_instance.should_receive(:send_invitation) { false }
        Invitations.perform
      end

      it { invitation.result.should be_falsey }
    end

  end
end
