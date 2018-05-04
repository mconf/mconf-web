# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ApplicationMailer do

  shared_examples 'footer e-mail' do
    it { mail_content(mail).should match(I18n.t('layouts.mailers.e_mail')) }
    it { mail_content(mail).should match(I18n.t('layouts.mailers.footer_title')) }
    it { mail_content(mail).should match(I18n.t('layouts.mailers.adress')) }
    it { mail_content(mail).should match(Regexp.escape(I18n.t('layouts.mailers.phone'))) }
    it { mail_content(mail).should match(I18n.t('layouts.mailers.unsubscribe')) }
    it { mail_content(mail).should match(Regexp.escape(I18n.t('layouts.mailers.question'))) }
    it ("Sets Linkdin image") { mail_content(mail).should match('assets/mailer/linkedin.png') }
    it ("Sets Medium image") { mail_content(mail).should match('assets/mailer/medium.png') }
    it ("Sets Facebook image") { mail_content(mail).should match('assets/mailer/facebook.png') }
  end

  describe '.feedback_email' do
    it ("Sets header logo image") { mail_content(mail).should match('mailer/mconf_tec.png') }
    let(:user) { FactoryGirl.create(:user) }
    let(:subject) { Forgery::LoremIpsum.characters 30 }
    let(:message) { Forgery::LoremIpsum.characters 140 }
    let(:mail) { ApplicationMailer.feedback_email(user.email, subject, message) }

    context "in the standard case" do
      it("sets 'to'") { mail.to.should eql([Site.current.smtp_receiver]) }
      it("sets 'subject'") {
        text = I18n.t('application_mailer.feedback_email.subject')
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([user.email]) }
      it("assigns @text") { mail_content(mail).should match(message) }
      it("assigns @email") { mail_content(mail).should match(user.email) }
      it("assings image_tag") {mail_content(mail).should match('assets/mailer/feedback.png')}
    end

    context "uses the current site's locale, not the sender's" do
      before {
        Site.current.update_attributes(:locale => "pt-br")
        user.update_attribute(:locale, "en")
      }
      it {
        content = I18n.t('application_mailer.feedback_email.content', :name => user.full_name, :email => user.email, :locale => "pt-br")
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
        content = I18n.t('application_mailer.feedback_email.content', :name => user.full_name, :email => user.email, :locale => "pt-br")
        mail_content(mail).should match(Regexp.escape(content))
      }
    end
    it_behaves_like 'footer e-mail'
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