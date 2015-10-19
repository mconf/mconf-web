# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe SpaceApprovedSenderWorker do
  let(:approver) { FactoryGirl.create(:user) }
  let(:worker) { SpaceApprovedSenderWorker }

  before {
    Site.current.update_attributes(require_space_approval: true)
  }

  it "uses the queue :space_notifications" do
    worker.instance_variable_get(:@queue).should eql(:space_notifications)
  end

  describe "#perform" do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space, approved: false) }
    let(:activity) { RecentActivity.last }

    context "when the activity has not been notified" do
      before {
        space.add_member!(user, 'Admin')
        space.approve!
        space.create_approval_notification(approver)
        worker.perform(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of_at_least(1) }
      it { SpaceMailer.should have_queued(:new_space_approved_email, user.id, space.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "when the activity has already been notified" do
      before {
        space.add_member!(user, 'Admin')
        space.approve!
        space.create_approval_notification(approver)
        activity.update_attributes(notified: true)
        worker.perform(activity.id)
      }

      it { SpaceMailer.should have_queue_size_of_at_least(0) }
      it { SpaceMailer.should_not have_queued(:new_space_approved_email, user.id, space.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end
  end

end
