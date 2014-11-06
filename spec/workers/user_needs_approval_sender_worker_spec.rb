# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe UserNeedsApprovalSenderWorker do
  let(:worker) { UserNeedsApprovalSenderWorker }

  before {
    Site.current.update_attributes(require_registration_approval: true)
  }

  it "uses the queue :user_notifications" do
    worker.instance_variable_get(:@queue).should eql(:user_notifications)
  end

  describe "#perform" do
    let(:user) { FactoryGirl.create(:user, approved_notification_sent_at: nil) }
    before { user.reload.approved_notification_sent_at.should be_nil }

    context "for a single recipient" do
      let(:recipient1) { FactoryGirl.create(:user) }
      let(:recipient_ids) {
        [ recipient1.id ]
      }

      before(:each) { worker.perform(user.id, recipient_ids) }

      it { AdminMailer.should have_queue_size_of(1) }
      it { AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient1.id, user.id).in(:mailer) }
      it { user.reload.needs_approval_notification_sent_at.should_not be_nil }
    end

    context "for multiple recipients" do
      let(:recipient1) { FactoryGirl.create(:user) }
      let(:recipient2) { FactoryGirl.create(:user) }
      let(:recipient3) { FactoryGirl.create(:user) }
      let(:recipient_ids) {
        [ recipient1.id, recipient2.id, recipient3.id ]
      }

      before(:each) { worker.perform(user.id, recipient_ids) }

      it { AdminMailer.should have_queue_size_of(3) }
      it { AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient1.id, user.id).in(:mailer) }
      it { AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient2.id, user.id).in(:mailer) }
      it { AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient3.id, user.id).in(:mailer) }
      it { user.reload.needs_approval_notification_sent_at.should_not be_nil }
    end
  end

end
