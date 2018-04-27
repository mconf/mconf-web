# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe InvoiceNotificationReportWorker, type: :worker do
  before {
    Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:update_customer).and_return(true)
  }

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

    context "if the report file exists and invoice_status is pending and notified false" do
      let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: date, notified: false,flag_invoice_status: "pending") }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/files/test-report-en.pdf"))
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(1) }
      it { expect(queue).to have_queued(paramsSendReport, invoice.id, user.id) }
    end

    context "if the report file exists and invoice_status is pending and notified true" do
      let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: date, notified: true,flag_invoice_status: "pending") }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/files/test-report-en.pdf"))
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(0) }
      it { expect(queue).not_to have_queued(paramsSendReport, invoice.id, user.id) }
    end

    context "if the report file exists and invoice_status is not pending and notified is false" do
      let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: date, notified: false,flag_invoice_status: "local") }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/files/test-report-en.pdf"))
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(0) }
      it { expect(queue).not_to have_queued(paramsSendReport, invoice.id, user.id) }
    end

    context "if the report file exists and invoice_status is not pending and notified is true" do
      let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: date, notified: true,flag_invoice_status: "local") }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/files/test-report-en.pdf"))
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(0) }
      it { expect(queue).not_to have_queued(paramsSendReport, invoice.id, user.id) }
    end

    context "if the report file doesn't exist and invoice_status is pending and notified false" do
      let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: date, notified: false,flag_invoice_status: "pending") }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/noFiles"))
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(0) }
      it { expect(queue).not_to have_queued(paramsSendReport, invoice.id, user.id) }
    end

    context "if the report file doesn't exist and invoice_status is pending and notified true " do
      let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: date, notified: true,flag_invoice_status: "pending") }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/noFiles"))
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(0) }
      it { expect(queue).not_to have_queued(paramsSendReport, invoice.id, user.id) }
    end

    context "if the report file doesn't exist and invoice_status is not pending and notified false" do
      let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: date, notified: false,flag_invoice_status: "local") }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/noFiles"))
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(0) }
      it { expect(queue).not_to have_queued(paramsSendReport, invoice.id, user.id) }
    end

    context "if the report file doesn't exist and invoice_status is not pending and notified true " do
      let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: date, notified: true,flag_invoice_status: "local") }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/noFiles"))
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(0) }
      it { expect(queue).not_to have_queued(paramsSendReport, invoice.id, user.id) }
    end

    context "doesn't resend subscriptions already sent" do
      let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
      let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
      let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: date, notified: false,flag_invoice_status: "pending") }

      before {
        Invoice.any_instance.stub(:report_file_path)
          .and_return(File.join(Rails.root, "spec/fixtures/files/test-report-en.pdf"))
      }
      before(:each) { worker.send_all_reports }

      it { expect(queue).to have_queue_size_of(1) }
      it { expect(queue).to have_queued(paramsSendReport, invoice.id, user.id) }
    end
  end

  describe "#send_report" do
    let(:date) { DateTime.strptime('02/01/2015 12:00', "%d/%m/%Y %H:%M") }
    let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
    let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, due_date: date, notified: false,flag_invoice_status: "pending") }

    before(:each) { worker.send_report(invoice.id, user.id) }

    it { InvoiceMailer.should have_queue_size_of(1) }
    it { InvoiceMailer.should have_queued(:invoice_report_email, user.id, invoice.id).in(:mailer) }
  end
end
