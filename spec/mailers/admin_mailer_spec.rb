# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"
require "capybara"

describe AdminMailer do

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

  describe '.new_user_waiting_for_approval' do
    it ("Sets header logo image") {
      mail_content(mail).should have_css("#accept")
     }
    let(:admin) { FactoryGirl.create(:superuser) }
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { AdminMailer.new_user_waiting_for_approval(admin.id, user.id) }

    context "in the standard case" do
      it("sets 'to'") { mail.to.should eql([admin.email]) }
      it("sets 'subject'") {
        text = I18n.t('admin_mailer.new_user_waiting_for_approval.subject')
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([Site.current.smtp_sender]) }
      it("assigns @user_name") {
        mail_content(mail).should match(user.name)
      }
      it("image_tag") { mail_content(mail).should have_css("#mconf-com") }
    end

    context "uses the receiver's locale" do
      before {
        Site.current.update_attributes(:locale => "en")
        admin.update_attribute(:locale, "pt-br")
        user.update_attribute(:locale, "en")
      }
      it {
        content = I18n.t('admin_mailer.new_user_waiting_for_approval.click_here', url: manage_users_url(host: Site.current.domain, q: user.email), locale: "pt-br")
        mail_content(mail).should match(Regexp.escape(content))
      }
    end

    context "uses the current site's locale if the receiver has no locale set" do
      before {
        Site.current.update_attributes(:locale => "pt-br")
        admin.update_attribute(:locale, nil)
        user.update_attribute(:locale, "en")
      }
      it {
        content = I18n.t('admin_mailer.new_user_waiting_for_approval.click_here', url: manage_users_url(host: Site.current.domain, q: user.email), locale: "pt-br")
        mail_content(mail).should match(Regexp.escape(content))
      }
    end

    context "uses the default locale if the site has no locale set" do
      before {
        Site.current.update_attributes(:locale => nil)
        I18n.default_locale = "pt-br"
        admin.update_attribute(:locale, nil)
        user.update_attribute(:locale, "en")
      }
      it {
        content = I18n.t('admin_mailer.new_user_waiting_for_approval.click_here', url: manage_users_url(host: Site.current.domain, q: user.email), locale: "pt-br")
        mail_content(mail).should match(Regexp.escape(content))
      }
    end
    it_behaves_like 'footer e-mail'
  end

  describe '.new_user_approved' do
    it ("Sets header logo image") { mail_content(mail).should have_css("#mconf-com") }
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { AdminMailer.new_user_approved(user.id) }

    context "in the standard case" do
      it("sets 'to'") { mail.to.should eql([user.email]) }
      it("sets 'subject'") {
        text = I18n.t('admin_mailer.new_user_approved.subject')
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([Site.current.smtp_sender]) }
      it("assigns @user_name") {
        mail_content(mail).should match(user.name)
      }
      it("image_tag") { mail_content(mail).should have_css("#app_by_admin") }
    end

    context "uses the receiver's locale" do
      before {
        Site.current.update_attributes(:locale => "en")
        user.update_attribute(:locale, "pt-br")
      }
      it {
        content = I18n.t('admin_mailer.new_user_approved.click_here', url: my_home_url(host: Site.current.domain), locale: "pt-br")
        mail_content(mail).should match(content)
      }
    end

    context "uses the current site's locale if the receiver has no locale set" do
      before {
        Site.current.update_attributes(:locale => "pt-br")
        user.update_attribute(:locale, nil)
      }
      it {
        content = I18n.t('admin_mailer.new_user_approved.click_here', url: my_home_url(host: Site.current.domain), locale: "pt-br")
        mail_content(mail).should match(content)
      }
    end

    context "uses the default locale if the site has no locale set" do
      before {
        Site.current.update_attributes(:locale => nil)
        I18n.default_locale = "pt-br"
        user.update_attribute(:locale, nil)
      }
      it {
        content = I18n.t('admin_mailer.new_user_approved.click_here', url: my_home_url(host: Site.current.domain), locale: "pt-br")
        mail_content(mail).should match(content)
      }
    end
    it_behaves_like 'footer e-mail'
  end

  context "calls the error handler on exceptions" do
    let(:exception) { Exception.new("test exception") }
    it {
      with_resque do
        BaseMailer.any_instance.stub(:render) { raise exception }
        Mconf::MailerErrorHandler.should_receive(:handle).with(AdminMailer, nil, exception, "new_user_waiting_for_approval", anything)
        AdminMailer.new_user_waiting_for_approval(1, 1).deliver
      end
    }
  end
end