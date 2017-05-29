# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe EventMailer do
  let(:invitation) { FactoryGirl.create(:event_invitation) }
  let(:mail) { EventMailer.invitation_email(invitation.id) }

  describe '.invitation_email' do

    context "if there's no recipient set in the invitation" do
      before {
        @invitation = Invitation.find(invitation.id)
        @invitation.update_attribute(:recipient_id, nil)
        @invitation.update_attribute(:recipient_email, nil)
      }
      let(:mail) { EventMailer.invitation_email(@invitation.id) }
      it("should return a null mail") {
        # TODO: didn't find a way to ensure mail is a ActionMailer::Base::NullMail
        mail.body.should be_empty
      }
    end

    context "when the recipient is a registered user" do
      before {
        # has a recipient but no recipient_email
        invitation.update_attributes(recipient_email: nil)
      }

      it("sets 'to'") { mail.to.should eql([invitation.recipient.email]) }
      it("sets 'subject'") {
        text = I18n.t('event_mailer.invitation_email.subject', event: invitation.target.name)
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([invitation.sender.email]) }
      it("assigns @invitation") {
        mail_content(mail).should match(invitation.title)
        mail_content(mail).should match(invitation.description)
        mail_content(mail).should match(invitation.url)
      }
    end

    it "uses the receiver's timezone for the dates"
    it "uses the site's timezone if the user has no timezone set"
    it "sends an .ics file attached"

    context "uses the receiver's locale" do
      before {
        Site.current.update_attributes(:locale => "en")
        invitation.recipient.update_attribute(:locale, "pt-br")
        invitation.sender.update_attribute(:locale, "en")
      }
      it {
        content = I18n.t('event_mailer.invitation_email.message.header',
                         sender: invitation.sender.name,
                         email_sender: invitation.sender.email,
                         event: invitation.target.name, locale: "pt-br")
        mail_content(mail).should match(Regexp.escape(content))
      }
    end

    context "uses the sender's locale if the receiver has no locale set" do
      before {
        Site.current.update_attributes(:locale => "en")
        invitation.recipient.update_attribute(:locale, nil)
        invitation.sender.update_attribute(:locale, "pt-br")
      }
      it {
        content = I18n.t('event_mailer.invitation_email.message.header',
                         sender: invitation.sender.name,
                         email_sender: invitation.sender.email,
                         event: invitation.target.name, locale: "pt-br")
        mail_content(mail).should match(Regexp.escape(content))
      }
    end

    context "uses the site's locale if the receiver has no locale set" do
      before {
        Site.current.update_attributes(:locale => "pt-br")
        invitation.recipient.update_attribute(:locale, nil)
        invitation.sender.update_attribute(:locale, nil)
      }
      it {
        content = I18n.t('event_mailer.invitation_email.message.header',
                         sender: invitation.sender.name,
                         email_sender: invitation.sender.email,
                         event: invitation.target.name, locale: "pt-br")
        mail_content(mail).should match(Regexp.escape(content))
      }
    end
  end

  context "calls the error handler on exceptions" do
    let(:exception) { Exception.new("test exception") }
    it {
      with_resque do
        BaseMailer.any_instance.stub(:render) { raise exception }
        Mconf::MailerErrorHandler.should_receive(:handle).with(EventMailer, nil, exception, "invitation_email", anything)
        EventMailer.invitation_email(invitation.id).deliver
      end
    }
  end
end
