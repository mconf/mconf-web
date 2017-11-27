# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe SubscriptionNotificationWorker, type: :worker do
  let(:worker) { SubscriptionNotificationWorker }
  let(:worker_sender) { SubscriptionSenderWorker }
  let(:queue) { Queue::High }
  let(:params) { { "method" => :perform, "class" => worker_sender.to_s } }
  let(:subscription) { FactoryGirl.create(:subscription) }
  subject { worker.perform }

  describe "#perform" do
    context "Activity subscription created" do
      let!(:activity) { FactoryGirl.create(:recent_activity, key: 'subscription.created', notified: nil, trackable: subscription) }
      before(:each) { worker.perform }

      it "activity.key == 'subscription.created'" do
        expect(queue).to have_queued(params, activity.id)
      end
    end

    context "Activity subscription destroyed" do
      let!(:activity) { FactoryGirl.create(:recent_activity, key: 'subscription.destroyed', notified: nil, trackable: subscription) }
      before(:each) { worker.perform }

      it "activity.key == 'subscription.destroyed'" do
        expect(queue).to have_queued(params, activity.id)
      end
    end
  end
end
