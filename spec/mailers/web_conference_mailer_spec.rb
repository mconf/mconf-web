# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe WebConferenceMailer do
  let(:invitation) { FactoryGirl.create(:web_conference_invitation) }
  let(:mail) { WebConferenceMailer.invitation_email(invitation.id) }

  describe '.invitation_email' do

    context "if there's no recipient set in the invitation" do
      before {
        @invitation = Invitation.find(invitation.id)
        @invitation.update_attribute(:recipient_id, nil)
        @invitation.update_attribute(:recipient_email, nil)
      }
      let(:mail) { WebConferenceMailer.invitation_email(@invitation.id) }
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
        text = I18n.t('web_conference_mailer.invitation_email.subject')
        text = "[#{Site.current.name}] #{text}"
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([invitation.sender.email]) }
      it("assigns @invitation") {
        mail.body.encoded.should match(invitation.title)
        mail.body.encoded.should match(invitation.description)
        mail.body.encoded.should match(invitation.url)
      }
      it("renders the attendee password if the room is private") {
        invitation.target.update_attributes(private: true)
        mail.body.encoded.should match(invitation.target.attendee_key)
      }
      it("renders the dial number") {
        invitation.target.update_attributes(dial_number: '12345')
        mail.body.encoded.should match('12345')
      }
      it("doesn't render the attendee password if the room is public") {
        invitation.target.update_attributes(private: false)
        mail.body.encoded.should_not match(invitation.target.attendee_key)
      }
    end

    it "uses the receiver's timezone for the start and end dates"
    it "uses the sender's timezone if the receiver has no timezone set"
    it "uses the site's timezone if the receiver and sender don't have a timezone set"
    it "sends an .ics file attached"

    context "uses the receiver's locale" do
      before {
        Site.current.update_attributes(:locale => "en")
        invitation.recipient.update_attribute(:locale, "pt-br")
        invitation.sender.update_attribute(:locale, "en")
      }
      it {
        content = I18n.t('web_conference_mailer.invitation_email.message.header',
                         sender: invitation.sender.name,
                         email_sender: invitation.sender.email, locale: "pt-br")
        mail.html_part.body.encoded.should match(Regexp.escape(content))
      }
    end

    context "uses the sender's locale if the receiver has no locale set" do
      before {
        Site.current.update_attributes(:locale => "en")
        invitation.recipient.update_attribute(:locale, nil)
        invitation.sender.update_attribute(:locale, "pt-br")
      }
      it {
        content = I18n.t('web_conference_mailer.invitation_email.message.header',
                         sender: invitation.sender.name,
                         email_sender: invitation.sender.email, locale: "pt-br")
        mail.html_part.body.encoded.should match(Regexp.escape(content))
      }
    end

    context "uses the site's locale if the receiver and sender don't have a locale set" do
      before {
        Site.current.update_attributes(:locale => "pt-br")
        invitation.recipient.update_attribute(:locale, nil)
        invitation.sender.update_attribute(:locale, nil)
      }
      it {
        content = I18n.t('web_conference_mailer.invitation_email.message.header',
                         sender: invitation.sender.name,
                         email_sender: invitation.sender.email, locale: "pt-br")
        mail.html_part.body.encoded.should match(Regexp.escape(content))
      }
    end
  end

  context "calls the error handler on exceptions" do
    let(:exception) { Exception.new("test exception") }
    it {
      with_resque do
        BaseMailer.any_instance.stub(:render) { raise exception }
        Mconf::MailerErrorHandler.should_receive(:handle).with(WebConferenceMailer, nil, exception, "invitation_email", anything)
        WebConferenceMailer.invitation_email(invitation.id).deliver
      end
    }
  end
end
