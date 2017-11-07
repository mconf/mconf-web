# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe InvoiceNotificationReportWorker, type: :worker do
	let(:worker) { InvoiceNotificationReportWorker }
	let(:user) { FactoryGirl.create(:user) }
  let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
  let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription, notified: false) }
  subject { worker.perform }

  describe "#perform" do

    context "Only invoices with notified = false" do

      context "File do not exist" do
        it "invoice.notified == false" do
          subject
          invoice.reload
          invoice.notified.should be(false)
        end
      end

      context "File exist" do
        # SEND THE EMAIL
        # see invoice_mailer_spec
        before {
          Invoice.any_instance.stub(:report_txt_file_path).and_return(File.join(Rails.root, "spec/fixtures/files/test-report-invoice.txt"))
        }
        it "invoice.notified == true" do
          subject
          invoice.reload
          invoice.notified.should be(true)
        end
      end
    end
  end
end
