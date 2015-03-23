# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe UserRegisteredByAdminSenderWorker do
  let(:worker) { UserRegisteredByAdminSenderWorker }

  it "uses the queue :user_notifications" do
    worker.instance_variable_get(:@queue).should eql(:user_notifications)
  end

  describe "#perform" do
    let(:user) { FactoryGirl.create(:user) }

    context "for a user created by an admin" do
      let(:activity) { RecentActivity.create(key: 'user.created_by_admin', trackable: user, notified: false) }

      before {
        worker.perform(activity.id)
      }

      it { UserMailer.should have_queue_size_of_at_least(1) }
      it { UserMailer.should have_queued(:registration_by_admin_notification_email, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end
  end

end
