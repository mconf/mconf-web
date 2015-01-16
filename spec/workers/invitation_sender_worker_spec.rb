# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe InvitationSenderWorker do
  let(:worker) { InvitationSenderWorker }

  it "uses the queue :join_requests" do
    worker.instance_variable_get(:@queue).should eql(:invitations)
  end

  describe "#perform" do

    context "sends the invitation and marks as sent" do
      let!(:invitation) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true, :result => false) }
      before { Invitation.any_instance.should_receive(:send_invitation) { true } }
      before(:each) { worker.perform(invitation.id) }
      it { invitation.reload.sent.should be(true) }
    end

    context "saves in the invitation the return if Invitation#send_invitation" do
      let!(:invitation) { FactoryGirl.create(:web_conference_invitation, :sent => false, :ready => true, :result => false) }

      context "when it returns false" do
        before { Invitation.any_instance.should_receive(:send_invitation) { false } }
        before(:each) { worker.perform(invitation.id) }
        it { invitation.reload.result.should be(false) }
      end

      context "when it returns true" do
        before { Invitation.any_instance.should_receive(:send_invitation) { true } }
        before(:each) { worker.perform(invitation.id) }
        it { invitation.reload.result.should be(true) }
      end
    end

  end
end
