# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ApplicationMailer do
  describe '.feedback_email' do
    let(:user) { FactoryGirl.create(:user) }
    let(:subject) { Forgery::LoremIpsum.characters 30 }
    let(:message) { Forgery::LoremIpsum.characters 140 }
    let(:mail) { ApplicationMailer.feedback_email(user.email, subject, message) }

    context "in the standard case" do
      it("sets 'to'") { mail.to.should eql([Site.current.smtp_receiver]) }
      it("sets 'subject'") {
        text = "#{I18n.t('application_mailer.feedback_email.subject')}: #{subject}"
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([user.email]) }
      it("assigns @text") { mail_content(mail).should match(message) }
      it("assigns @email") { mail_content(mail).should match(user.email) }
    end

    context "uses the current site's locale, not the sender's" do
      before {
        Site.current.update_attributes(:locale => "pt-br")
        user.update_attribute(:locale, "en")
      }
      it {
        content = I18n.t('application_mailer.feedback_email.content', :email => user.email, :locale => "pt-br")
        mail_content(mail).should match(Regexp.escape(content))
      }
    end

    context "uses the default locale if the site has no locale set" do
      before {
        Site.current.update_attributes(:locale => nil)
        I18n.default_locale = "pt-br"
        user.update_attribute(:locale, "en")
      }
      it {
        content = I18n.t('application_mailer.feedback_email.content', :email => user.email, :locale => "pt-br")
        mail_content(mail).should match(Regexp.escape(content))
      }
    end
  end

  context "calls the error handler on exceptions" do
    let(:exception) { Exception.new("test exception") }
    it {
      with_resque do
        BaseMailer.any_instance.stub(:render) { raise exception }
        Mconf::MailerErrorHandler.should_receive(:handle).with(ApplicationMailer, nil, exception, "feedback_email", anything)
        ApplicationMailer.feedback_email("any", "any", "any").deliver
      end
    }
  end
end
