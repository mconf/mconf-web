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
      it("sets 'to'") { mail.to.should eql([Site.current.smtp_sender]) }
      it("sets 'subject'") {
        text = "[#{Site.current.name}] #{I18n.t('application_mailer.feedback_email.subject')}: #{subject}"
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([user.email]) }
      it("assigns @text") { mail.body.encoded.should match(message) }
      it("assigns @email") { mail.body.encoded.should match(user.email) }
    end

    context "uses the current site's locale, not the sender's" do
      before {
        Site.current.update_attributes(:locale => "pt-br")
        user.update_attribute(:locale, "en")
      }
      it {
        content = I18n.t('application_mailer.feedback_email.content', :email => user.email, :locale => "pt-br")
        mail.body.encoded.should match(Regexp.escape(content))
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
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end
  end

  describe ".digest_email" do
    let(:user) { FactoryGirl.create(:user, :locale => "pt-br") }
    let(:space) { FactoryGirl.create(:space) }
    let(:now) { Time.now }
    let(:date_start) { now - 1.day }
    let(:date_end) { now }

    before {
      # create the data to be returned
      user.update_attributes(:receive_digest => User::RECEIVE_DIGEST_DAILY)
      @posts = [ FactoryGirl.create(:post, :space => space, :updated_at => date_start).id ]
      @news = [ FactoryGirl.create(:news, :space => space, :updated_at => date_start).id ]
      @attachments = [ FactoryGirl.create(:attachment, author: user, :space => space, :updated_at => date_start).id ]
      @events = [ FactoryGirl.create(:event, :owner => space, :start_on => date_start, :end_on => date_start + 1.hour).id ]
      @inbox = [ FactoryGirl.create(:private_message, :receiver => user, :sender => FactoryGirl.create(:user)).id ]
      @locale = user.locale
    }

    let(:mail) { ApplicationMailer.digest_email(user.id, @posts, @news, @attachments, @events, @inbox) }

    describe "in the standard case" do
      it("sets 'to'") { mail.to.should eql([user.email]) }
      it("sets 'subject'") {
        text = I18n.t('email.digest.title', :type => I18n.t('email.digest.type.daily', :locale => @locale), :locale => @locale)
        text = "[#{Site.current.name}] #{text}"
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      # it("sets 'reply_to'") { mail.reply_to.should eql([user.email]) }
      it "includes the correct information in the email"
    end

    context "uses the site's locale if the user has no locale set" do
      before {
        Site.current.update_attributes(:locale => "pt-br")
        user.update_attribute(:locale, nil)
      }
      it {
        text = I18n.t('email.digest.title', :type => I18n.t('email.digest.type.daily', :locale => "pt-br"), :locale => "pt-br")
        text = "[#{Site.current.name}] #{text}"
        mail.subject.should eql(text)
      }
      it {
        content = I18n.t('email.digest.message', :locale => "pt-br")
        mail.body.encoded.should match(content)
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
