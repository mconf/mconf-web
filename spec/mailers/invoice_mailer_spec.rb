# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe InvoiceMailer do
  let(:user) { FactoryGirl.create(:user) }
  let!(:subscription) { FactoryGirl.create(:subscription, user: user) }
  let!(:invoice) { FactoryGirl.create(:invoice, subscription: subscription) }

  describe '.invoice_report_email' do

    context "File do not exist" do
      it { invoice.notified.should be(false) }
    end

    context "File exist" do
      before {
        Invoice.any_instance.stub(:report_txt_file_path).and_return(File.join(Rails.root, "spec/fixtures/files/test-report-invoice.txt"))
      }
      let(:date) { (invoice.due_date - 1.month).strftime("%Y-%m") }
      let(:mail) { InvoiceMailer.invoice_report_email(user.id, invoice.id, date) }
      let(:url) { "www.test.com" }

      it("sets 'to'") { mail.to.should eql([user.email]) }
      it("sets 'subject'") {
        text = I18n.t('invoice_mailer.subject')
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("assigns @user") { mail.body.encoded.should match(user.name) }
      it("sends a .txt file attached") {
        mail.attachments.should have(4).attachment
        attachment = mail.attachments[0]
        attachment.should be_a_kind_of(Mail::Part)
        attachment.filename.should eql('invoice-report.txt')
      }
      it("renders the link to see all the subscriptions with all invoices") {
        allow_any_instance_of( Rails.application.routes.url_helpers ).to receive(:user_subscription_url).and_return(url)
        content = I18n.t('invoice_mailer.invoice_report_email.message.link', :url => url).html_safe
        mail_content(mail).should match(content)
      }
    end
  end
end
