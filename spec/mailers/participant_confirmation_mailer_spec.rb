# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe ParticipantConfirmationMailer do

  describe '.confirmation_email' do
    let(:participant) { FactoryGirl.create(:participant, email: 'son@icbo.om') }
    let(:pc) { FactoryGirl.create(:participant_confirmation, participant: participant) }
    let(:mail) { ParticipantConfirmationMailer.confirmation_email(pc.id) }
    let(:url) { participant_confirmation_path(token: pc.token, host: Site.current.domain) }

    context "in the standard case" do
      it("sets 'to'") { mail.to.should eql([pc.email]) }
      it("sets 'subject'") {
        text = I18n.t('participant_confirmation_mailer.confirmation_email.subject', event: participant.event.name)
        text = "[#{Site.current.name}] #{text}"
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([Site.current.smtp_sender]) }
      it("assigns @token") {
        mail.body.encoded.should match(pc.token)
      }
      it("assigns @event") {
        mail.body.encoded.should match(participant.event.name)
      }
      it("assigns @mail") {
        mail.body.encoded.should match(pc.email)
      }
      it("sends a link to the confirmation page") {
        mail.body.encoded.should match(url)
      }
    end

    context "uses the current site's locale if the receiver has no locale set" do
      before {
        Site.current.update_attributes(:locale => "pt-br")
      }
      it {
        content = I18n.t('participant_confirmation_mailer.confirmation_email.subject', event: participant.event.name, locale: "pt-br")
        mail.subject.should match(content)
      }
    end

    context "uses the default locale if the site has no locale set" do
      before {
        Site.current.update_attributes(:locale => nil)
        I18n.default_locale = "pt-br"
      }
      it {
        content = I18n.t('participant_confirmation_mailer.confirmation_email.subject', event: participant.event.name, locale: "pt-br")
        mail.subject.should match(content)
      }
    end
  end

  context "calls the error handler on exceptions" do
    let(:exception) { Exception.new("test exception") }
    it {
      with_resque do
        ParticipantConfirmationMailer.any_instance.stub(:confirmation_email) { raise exception }
        Mconf::MailerErrorHandler.should_receive(:handle).with(ParticipantConfirmationMailer, nil, exception, "confirmation_email", anything)
        ParticipantConfirmationMailer.confirmation_email(nil).deliver
      end
    }
  end
end
