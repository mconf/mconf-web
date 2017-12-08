# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe SubscriptionSenderWorker, type: :worker do
  before {
    Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:update_customer).and_return(true)
  }

  let(:worker) { SubscriptionSenderWorker }
  let(:subscription) { FactoryGirl.create(:subscription) }
  let(:user) { FactoryGirl.create(:user) }

  describe "#perform" do
    context "Only activity.notified == false AND activity.trackable.present" do
      # SEND THE EMAIL
      # see subscription_mailer_spec
      let(:activity) { FactoryGirl.create(:recent_activity, notified: false, trackable: subscription, recipient: user) }

      it "activity.notified == true" do
        worker.perform(activity.id)
        activity.reload
        activity.notified.should be(true)
      end
    end

    context "Activity.notified == true OR activity.trackable not present" do
      context "Activity.notified == true" do
        let(:activity) { FactoryGirl.create(:recent_activity, notified: true, trackable: subscription) }

        it "Dont update (still true) and dont send the email" do
          worker.perform(activity.id)
          activity.reload
          activity.notified.should be(true)
        end
      end

      context "Activity.trackable not present" do
        let(:activity) { FactoryGirl.create(:recent_activity, notified: false, trackable: nil) }

        it "Dont update (still false) and dont send the email" do
          worker.perform(activity.id)
          activity.reload
          activity.notified.should be(false)
        end
      end
    end
  end
end
