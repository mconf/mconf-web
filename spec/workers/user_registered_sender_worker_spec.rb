# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe UserRegisteredSenderWorker do
  let(:worker) { UserRegisteredSenderWorker }

  it "uses the queue :user_notifications" do
    worker.instance_variable_get(:@queue).should eql(:user_notifications)
  end

  describe "#perform" do
    let(:user) { FactoryGirl.create(:user) }

    context "when the activity is already notified" do
      let(:token) { FactoryGirl.create(:ldap_token, user: user) }
      let(:activity) {
        RecentActivity.create(
          key: 'ldap.user.created', owner: token, trackable: user, notified: false
        )
      }

      before {
        activity.update_attributes(notified: true)
        worker.perform(activity.id)
      }

      it { UserMailer.should have_queue_size_of(0) }
      it { UserMailer.should_not have_queued(:registration_notification_email, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end


    context "for a user created via LDAP" do
      let(:token) { FactoryGirl.create(:ldap_token, user: user) }
      let(:activity) {
        RecentActivity.create(
          key: 'ldap.user.created', owner: token, trackable: user, notified: false
        )
      }

      before {
        worker.perform(activity.id)
      }

      it { UserMailer.should have_queue_size_of_at_least(1) }
      it { UserMailer.should have_queued(:registration_notification_email, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end

    context "for a user created via Shibboleth" do
      let(:token) { FactoryGirl.create(:shib_token, user: user) }
      let(:activity) {
        RecentActivity.create(
          key: 'shib.user.created', owner: token, trackable: user, notified: false
        )
      }

      before {
        worker.perform(activity.id)
      }

      it { UserMailer.should have_queue_size_of_at_least(1) }
      it { UserMailer.should have_queued(:registration_notification_email, user.id).in(:mailer) }
      it { activity.reload.notified.should be(true) }
    end
  end

end
