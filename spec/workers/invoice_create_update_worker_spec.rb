# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2017 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe InvoiceCreateUpdateWorker, type: :worker do
  let(:worker) { InvoiceCreateUpdateWorker }
  let(:worker_post) { InvoicePostWorker }
  let(:queue) { Queue::High }
  let(:params) { { "method" => :perform, "class" => worker_post.to_s } }
  subject { worker.perform }

  describe "#perform" do
    let!(:user) { FactoryGirl.create(:user, trial_expires_at: DateTime.now - 1.day) }
    let!(:subscription) { FactoryGirl.create(:subscription, user: user, pay_day: "2017-12-10") }

    context "there is one invoice for the subscription and it is for this month" do
      let!(:previous_invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: DateTime.now.change({day: 10}) - 1.month) }
      let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, user_qty: 5, due_date: DateTime.now.change({day: 10})) }
      before { Invoice.any_instance.stub(:get_unique_users_for_invoice).and_return(0) }

      it "updates to the number of users in the invoice" do
        subject
        invoice.reload
        invoice.user_qty.should eql(0)
      end
    end

    context "there is no invoice for the subscription" do
      before { Invoice.any_instance.stub(:get_unique_users_for_invoice).and_return(4) }

      it "creates a new invoice" do
        expect { subject }.to change{ Invoice.count }.by(1)
      end

      it "sets the user quantity in the new invoice" do
        subject
        subscription.invoices.last.reload
        subscription.invoices.last.user_qty.should eql(4)
      end

      it "set the days consumed in the new invoice" do
        consumed = if DateTime.now.day >= Rails.application.config.base_month_days
                     nil
                   else
                     Rails.application.config.base_month_days - DateTime.now.day
                   end
        subject
        subscription.invoices.last.reload
        subscription.invoices.last.days_consumed.should be(consumed.to_i)
      end
    end

    context "there are invoices for the subscription but for this month" do
      let!(:other_invoice) { FactoryGirl.create(:invoice, subscription: subscription,
                                                due_date: DateTime.now.change({day: 10}) - 2.month) }
      let!(:previous_invoice) { FactoryGirl.create(:invoice, subscription: subscription,
                                                   due_date: DateTime.now.change({day: 10}) - 1.month) }
      before { Invoice.any_instance.stub(:get_unique_users_for_invoice).and_return(6) }

      it "creates a new invoice" do
        expect { subject }.to change{ Invoice.count }.by(1)
      end

      it "sets the user quantity in the new invoice" do
        subject
        subscription.invoices.last.reload
        subscription.invoices.last.user_qty.should eql(6)
      end
    end
  end
end
