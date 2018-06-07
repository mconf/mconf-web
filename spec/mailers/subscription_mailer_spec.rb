# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe SubscriptionMailer do
  before {
    Mconf::Iugu.stub(:create_plan).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_subscription).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:create_customer).and_return(Forgery::CreditCard.number)
    Mconf::Iugu.stub(:update_customer).and_return(true)
  }
  let(:user) { FactoryGirl.create(:user) }
  let!(:subscription) { FactoryGirl.create(:subscription, user: user) }

  shared_examples 'footer e-mail' do
    it { mail_content(mail).should match(I18n.t('layouts.mailers.e_mail')) }
    it { mail_content(mail).should match(I18n.t('layouts.mailers.footer_title')) }
    it { mail_content(mail).should match(I18n.t('layouts.mailers.adress')) }
    it { mail_content(mail).should match(Regexp.escape(I18n.t('layouts.mailers.phone'))) }
    it { mail_content(mail).should match(I18n.t('layouts.mailers.unsubscribe')) }
    it { mail_content(mail).should match(Regexp.escape(I18n.t('layouts.mailers.question'))) }
    it ("Sets Linkdin image") { mail_content(mail).should have_css("#facebook") }
    it ("Sets Medium image") { mail_content(mail).should have_css("#linkedin") }
    it ("Sets Facebook image") { mail_content(mail).should have_css("#medium") }
  end

  describe '.subscription_created_notification_email' do
    let(:mail) { SubscriptionMailer.subscription_created_notification_email(user.id) }
    let(:url) { "www.test.com" }
    it ("Sets header logo image") { mail_content(mail).should have_css("#mconf-com") }
    context "attendee_key.present" do
      let(:room) { FactoryGirl.create(:bigbluebutton_room, owner: user, attendee_key: "123") }
    end

    it("sets 'to'") { mail.to.should eql([user.email]) }
    it("sets 'subject'") do
      text = I18n.t('subscription_mailer.subscription_created_notification_email.subject', :name => user.name)
      mail.subject.should eql(text)
    end
    it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
    it("sets 'headers'") { mail.headers.should eql({}) }
    it_behaves_like 'footer e-mail'
    it("image_tag") { mail_content(mail).should have_css("#subs_created") }
  end

  describe '.subscription_destroyed_notification_email' do
    let(:mail) { SubscriptionMailer.subscription_destroyed_notification_email(user.id) }
    let(:url) { "www.contact.com" }
    it ("Sets header logo image") { mail_content(mail).should have_css("#mconf-com") }
    it("sets 'to'") { mail.to.should eql([user.email]) }
    it("sets 'subject'") do
      text = I18n.t('subscription_mailer.subscription_destroyed_notification_email.subject', :name => user.name)
      mail.subject.should eql(text)
    end
    it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
    it("sets 'headers'") { mail.headers.should eql({}) }
    it_behaves_like 'footer e-mail'
    it("image_tag") { mail_content(mail).should have_css("#subs_cancel") }
  end

  describe '.subscription_enabled_notification_email' do
    let(:mail) { SubscriptionMailer.subscription_enabled_notification_email(user.id) }
    let(:url) { "www.contact.com" }
    it ("Sets header logo image") { mail_content(mail).should have_css("#mconf-com") }
    it("sets 'to'") { mail.to.should eql([user.email]) }
    it("sets 'subject'") do
      text = I18n.t('subscription_mailer.subscription_enabled_notification_email.subject', :name => user.name)
      mail.subject.should eql(text)
    end
    it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
    it("sets 'headers'") { mail.headers.should eql({}) }
    it_behaves_like 'footer e-mail'
  end
end
