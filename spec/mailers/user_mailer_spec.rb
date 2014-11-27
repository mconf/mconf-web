# This file is part of  Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe UserMailer do

  describe '.registration_notification_email' do
    let(:user) { FactoryGirl.create(:user) }
    let(:mail) { UserMailer.registration_notification_email(user.id) }
    let(:url) { "#{Site.current.domain}/home" }

    context "in the standard case" do
      it("sets 'to'") { mail.to.should eql([user.email]) }
      it("sets 'subject'") {
        text = I18n.t('user_mailer.registration_notification_email.subject')
        text = "[#{Site.current.name}] #{text}"
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([Site.current.smtp_sender]) }
      it("assigns @user_name") {
        mail.body.encoded.should match(user.name)
      }
      it("sends a link to the users home_path") {
        content = I18n.t('user_mailer.registration_notification_email.click_here', url: url)
        mail.body.encoded.should match(content)
      }
    end

    context "uses the receiver's locale" do
      before {
        Site.current.update_attributes(:locale => "en")
        user.update_attribute(:locale, "pt-br")
      }
      it {
        content = I18n.t('user_mailer.registration_notification_email.subject', locale: "pt-br")
        mail.body.encoded.should match(content)
      }
    end

    context "uses the current site's locale if the receiver has no locale set" do
      before {
        Site.current.update_attributes(:locale => "pt-br")
        user.update_attribute(:locale, nil)
      }
      it {
        content = I18n.t('user_mailer.registration_notification_email.subject', locale: "pt-br")
        mail.body.encoded.should match(content)
      }
    end

    context "uses the default locale if the site has no locale set" do
      before {
        Site.current.update_attributes(:locale => nil)
        I18n.default_locale = "pt-br"
        user.update_attribute(:locale, nil)
      }
      it {
        content = I18n.t('user_mailer.registration_notification_email.subject', locale: "pt-br")
        mail.body.encoded.should match(content)
      }
    end
  end

  context "calls the error handler on exceptions" do
    let(:exception) { Exception.new("test exception") }
    it {
      with_resque do
        BaseMailer.any_instance.stub(:render) { raise exception }
        Mconf::MailerErrorHandler.should_receive(:handle).with(UserMailer, nil, exception, "registration_notification_email", anything)
        UserMailer.registration_notification_email(1).deliver
      end
    }
  end
end
