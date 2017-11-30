# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe InvoiceNotificationReportWorker, type: :worker do
	let(:worker) { InvoiceNotificationReportWorker }
	let(:user) { FactoryGirl.create(:user) }
  let(:queue) { Queue::High }
  let(:paramsSendReport) { {"method"=>:send_report, "class"=>worker.to_s} }

  describe "#perform" do
    before { worker.should_receive(:send_all_reports).once }
    it { worker.perform }
  end

  describe "#send_all_reports" do
    let(:user2) { FactoryGirl.create(:user) }

    context "if the report file exists" do
      let(:date1) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let(:date2) { DateTime.strptime('10/12/2017 02:00', "%d/%m/%Y %H:%M") }
      let!(:subscription1) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice1) { FactoryGirl.create(:invoice, subscription: subscription1, due_date: date1, notified: false) }
      let!(:subscription2) { FactoryGirl.create(:subscription, user: user2) }
      let!(:invoice2) { FactoryGirl.create(:invoice, subscription: subscription2, due_date: date2, notified: false) }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/files/test-report-en.pdf"))
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(2) }
      it { expect(queue).to have_queued(paramsSendReport, invoice1.id, user.id, "2014-12") }
      it { expect(queue).to have_queued(paramsSendReport, invoice2.id, user2.id, "2017-11") }
    end

    context "if the report file doesn't exist" do
      let(:date1) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let(:date2) { DateTime.strptime('10/12/2017 02:00', "%d/%m/%Y %H:%M") }
      let!(:subscription1) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice1) { FactoryGirl.create(:invoice, subscription: subscription1, due_date: date1, notified: false) }
      let!(:subscription2) { FactoryGirl.create(:subscription, user: user2) }
      let!(:invoice2) { FactoryGirl.create(:invoice, subscription: subscription2, due_date: date2, notified: false) }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/files/test-report-en.pdf"))
        File.should_receive(:exists?).once.and_return(true)
        File.should_receive(:exists?).once.and_return(false)
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(1) }
      it { expect(queue).to have_queued(paramsSendReport, invoice1.id, user.id, "2014-12") }
      it { expect(queue).not_to have_queued(paramsSendReport, invoice2.id, user2.id, "2017-11") }
    end

    context "doesn't resend subscriptions already sent" do
      let(:date1) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let(:date2) { DateTime.strptime('10/12/2017 02:00', "%d/%m/%Y %H:%M") }
      let!(:subscription1) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice1) { FactoryGirl.create(:invoice, subscription: subscription1, due_date: date1, notified: false) }
      let!(:subscription2) { FactoryGirl.create(:subscription, user: user2) }
      let!(:invoice2) { FactoryGirl.create(:invoice, subscription: subscription2, due_date: date2, notified: true) }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/files/test-report-en.pdf"))
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(1) }
      it { expect(queue).to have_queued(paramsSendReport, invoice1.id, user.id, "2014-12") }
      it { expect(queue).not_to have_queued(paramsSendReport, invoice2.id, user2.id, "2017-11") }
    end
  end

  describe "#send_report" do
    let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
    let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
    let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: date, notified: false) }

    before(:each) { worker.send_report(invoice.id, user.id, "2014-12") }

    it { InvoiceMailer.should have_queue_size_of(1) }
    it { InvoiceMailer.should have_queued(:invoice_report_email, user.id, invoice.id).in(:mailer) }
  end
end
