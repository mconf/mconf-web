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

    context "There is one invoice for the subscription and it is for this month" do
      let!(:old_invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: (DateTime.now.change({day: 10})-1.month)) }
      let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: (DateTime.now.change({day: 10}))) }

      # FYI: secondtolast = subscription.invoices.offset(1).last
      context "secondtolast.present" do
        it "Queue::High.enqueue(InvoicePostWorker, :perform, secondtolast.id)" do
          subject
          expect(queue).to have_queued(params, old_invoice.id)
        end
      end

      before {  Invoice.any_instance.stub(:get_unique_users_for_invoice).and_return(0) }
      it "invoice.user_qty: unique_total (0)" do
        subject
        invoice.reload
        invoice.user_qty.should eql(0)
      end
    end

    context "There is none invoice for the subscription" do
      before {  Invoice.any_instance.stub(:get_unique_users_for_invoice).and_return(0) }
      it "invoice.user_qty: unique_total (0)" do
        subject
        subscription.invoices.last.reload
        subscription.invoices.last.user_qty.should eql(0)
      end
      it "invoice.days_consumed: consumed)" do
        consumed = DateTime.now.day >= Rails.application.config.base_month_days ? nil : (Rails.application.config.base_month_days - DateTime.now.day)
        subject
        subscription.invoices.last.reload
        subscription.invoices.last.days_consumed.should be(consumed.to_i)
      end
    end

    context "There is one invoice for the subscription but it is not for this month" do
      let!(:old_invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: (DateTime.now.change({day: 10})-1.month)) }

      # FYI: secondtolast = subscription.invoices.offset(1).last
      context "secondtolast.present" do
        it "Queue::High.enqueue(InvoicePostWorker, :perform, secondtolast.id)" do
          subject
          expect(queue).to have_queued(params, old_invoice.id)
        end
      end

      before {  Invoice.any_instance.stub(:get_unique_users_for_invoice).and_return(0) }
      it "invoice.user_qty: unique_total (0)" do
        subject
        subscription.invoices.last.reload
        subscription.invoices.last.user_qty.should eql(0)
      end
    end
  end
end
