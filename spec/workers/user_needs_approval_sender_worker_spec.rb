# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
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
    let(:user) { FactoryGirl.create(:user) }
    let(:activity) { RecentActivity.where(trackable_type: 'User', key: 'user.created',
      trackable_id: user.id, notified: [false, nil]).first }

    context "for an already notified activity" do
      let(:recipient1) { FactoryGirl.create(:user) }
      let(:recipient_ids) {
        [ recipient1.id ]
      }

      before(:each) {
        activity.update_attributes(notified: true)
        worker.perform(activity.id, recipient_ids)
      }

      it { AdminMailer.should have_queue_size_of(0) }
      it { AdminMailer.should_not have_queued(:new_user_waiting_for_approval, recipient1.id, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end


    context "for a single recipient" do
      let(:recipient1) { FactoryGirl.create(:user) }
      let(:recipient_ids) {
        [ recipient1.id ]
      }

      before(:each) { worker.perform(activity.id, recipient_ids) }

      it { AdminMailer.should have_queue_size_of_at_least(1) }
      it { AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient1.id, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for multiple recipients" do
      let(:recipient1) { FactoryGirl.create(:user) }
      let(:recipient2) { FactoryGirl.create(:user) }
      let(:recipient3) { FactoryGirl.create(:user) }
      let(:recipient_ids) {
        [ recipient1.id, recipient2.id, recipient3.id ]
      }

      before {
        worker.perform(activity.id, recipient_ids)
      }
      it { AdminMailer.should have_queue_size_of_at_least(3) }
      it {
        AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient1.id, user.id).in(:mailer)
        AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient2.id, user.id).in(:mailer)
        AdminMailer.should have_queued(:new_user_waiting_for_approval, recipient3.id, user.id).in(:mailer)
      }
      it { activity.reload.notified.should be(true) }
    end
  end

end
