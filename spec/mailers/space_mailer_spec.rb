# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe SpaceMailer do
  let(:join_request) { FactoryGirl.create(:space_join_request) }
  let(:introducer) { join_request.introducer }
  let(:candidate) { join_request.candidate }
  let(:space) { join_request.group }

  describe '.invitation_email' do
    let(:mail) { SpaceMailer.invitation_email(join_request.id) }

    context "in the standard case" do
      it("sets 'to'") { mail.to.should eql([join_request.email]) }
      it("sets 'subject'") {
        text = "[#{Site.current.name}] #{I18n.t('space_mailer.invitation_email.subject', :space => space.name, :username => introducer.full_name)}"
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([introducer.email]) }
      it("assigns @user") { mail.body.encoded.should match(introducer.full_name) }
      it("assigns @space") { mail.body.encoded.should match(space.name) }
      it("renders the link to accept the invitation") {
        url = space_join_request_url(space, join_request, :host => Site.current.domain)
        url2 = space_url(space, :host => Site.current.domain)
        content = I18n.t('space_mailer.invitation_email.message.link', :url => url, :space_url => url2).html_safe
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end

    context "uses the candidate's locale" do
      before {
        Site.current.update_attributes(:locale => "en")
        introducer.update_attribute(:locale, "en")
        candidate.update_attribute(:locale, "pt-br")
      }
      it {
        content = I18n.t('space_mailer.invitation_email.message.header', :sender => introducer.full_name,
                         :email_sender => introducer.email, :space => space.name, :locale => "pt-br")
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end

    context "uses the site's default locale if the candidate has no locale set" do
      before {
        introducer.update_attribute(:locale, "en")
        candidate.update_attribute(:locale, nil)
        Site.current.update_attributes(:locale => "pt-br")
      }
      it {
        content = I18n.t('space_mailer.invitation_email.message.header', :sender => introducer.full_name,
                         :email_sender => introducer.email, :space => space.name, :locale => "pt-br")
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end
  end

  describe ".processed_invitation_email" do
    let(:join_request) { FactoryGirl.create(:space_join_request, :request_type => 'invite') }
    let(:mail) { SpaceMailer.processed_invitation_email(join_request.id) }
    let(:introducer) { join_request.introducer }
    let(:space) { join_request.group }

    before { join_request.update_attributes(accepted: true) }

    context "when the join request was accepted" do
      it("sets 'to'") { mail.to.should eql([introducer.email]) }
      it("sets 'subject'") {
        text = I18n.t("space_mailer.processed_invitation_email.subject",
                      :name => candidate.name,
                      :action => I18n.t("space_mailer.processed_invitation_email.accepted"))
        text = "[#{Site.current.name}] #{text}"
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([]) }
      it("assigns @space") { mail.body.encoded.should match(space.name) }
      it("assigns @candidate, @introducer and @action") {
        action = I18n.t("space_mailer.processed_invitation_email.accepted")
        content = I18n.t("space_mailer.processed_invitation_email.message.header",
                         :introducer => introducer.name,
                         :name => candidate.name,
                         :action => action,
                         :space => space.name)
        mail.body.encoded.should match(content)
      }
      it("renders a link to the list of users in the space") {
        url = space_users_url(space, :host => Site.current.domain)
        content = I18n.t('space_mailer.processed_invitation_email.message.link', :users_url => url).html_safe
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end

    context "when the join request was rejected" do
      before { join_request.update_attributes(accepted: false) }

      it("sets 'subject'") {
        text = I18n.t("space_mailer.processed_invitation_email.subject",
                      :name => candidate.name,
                      :action => I18n.t("space_mailer.processed_invitation_email.rejected"))
        text = "[#{Site.current.name}] #{text}"
        mail.subject.should eql(text)
      }
      it("assigns @candidate, @introducer and @action") {
        action = I18n.t("space_mailer.processed_invitation_email.rejected")
        content = I18n.t("space_mailer.processed_invitation_email.message.header",
                         :introducer => introducer.name,
                         :name => candidate.name,
                         :action => action,
                         :space => space.name)
        mail.body.encoded.should match(content)
      }
      it("renders a link to the list of users in the space") {
        url = space_users_url(space, :host => Site.current.domain)
        content = I18n.t('space_mailer.processed_invitation_email.message.link', :users_url => url).html_safe
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end

    context "uses the introducer's locale" do
      before {
        Site.current.update_attributes(:locale => "en")
        introducer.update_attribute(:locale, "pt-br")
        candidate.update_attribute(:locale, "en")
      }
      it {
        action = I18n.t("space_mailer.processed_invitation_email.accepted",
                        :locale => "pt-br")
        content = I18n.t("space_mailer.processed_invitation_email.message.header",
                         :introducer => introducer.name,
                         :name => candidate.name,
                         :action => action,
                         :space => space.name,
                         :locale => "pt-br")
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end

    context "uses the site's default locale if the introducer has no locale set" do
      before {
        introducer.update_attribute(:locale, nil)
        candidate.update_attribute(:locale, "en")
        Site.current.update_attributes(:locale => "pt-br")
      }
      it {
        action = I18n.t("space_mailer.processed_invitation_email.accepted",
                        :locale => "pt-br")
        content = I18n.t("space_mailer.processed_invitation_email.message.header",
                         :introducer => introducer.name,
                         :name => candidate.name,
                         :action => action,
                         :space => space.name,
                         :locale => "pt-br")
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end
  end

  describe ".join_request_email" do
    let(:receiver) { FactoryGirl.create(:user) }
    let(:mail) { SpaceMailer.join_request_email(join_request.id, receiver.id) }

    context "in the standard case" do
      it("sets 'to'") { mail.to.should eql([receiver.email]) }
      it("sets 'subject'") {
        text = I18n.t('space_mailer.join_request_email.subject',
                      :candidate => candidate.name, :space => space.name)
        text = "[#{Site.current.name}] #{text}"
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([candidate.email]) }
      it("assigns @join_request") { mail.body.encoded.should match(join_request.comment) }
      it("renders the link to accept the join request") {
        url = space_join_requests_url(space, host: Site.current.domain)
        content = I18n.t('space_mailer.join_request_email.message.link', :url => url).html_safe
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end

    context "uses the receiver's locale" do
      before {
        Site.current.update_attributes(:locale => "en")
        introducer.update_attribute(:locale, "en")
        candidate.update_attribute(:locale, "en")
        receiver.update_attribute(:locale, "pt-br")
      }
      it {
        content = I18n.t('space_mailer.join_request_email.message.header', :candidate => candidate.full_name,
                         :space => space.name, :locale => "pt-br")
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end

    context "uses the site's default locale if the receiver has no locale set" do
      before {
        introducer.update_attribute(:locale, "en")
        candidate.update_attribute(:locale, "en")
        receiver.update_attribute(:locale, nil)
        Site.current.update_attributes(:locale => "pt-br")
      }
      it {
        content = I18n.t('space_mailer.join_request_email.message.header', :candidate => candidate.full_name,
                         :space => space.name, :locale => "pt-br")
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end
  end

  describe ".processed_join_request_email" do
    let(:mail) { SpaceMailer.processed_join_request_email(join_request.id) }

    before { join_request.update_attributes(accepted: true) }

    context "when the join request was approved" do
      it("sets 'to'") { mail.to.should eql([candidate.email]) }
      it("sets 'subject'") {
        text = I18n.t("space_mailer.processed_join_request_email.subject",
                      :space => space.name,
                      :action => I18n.t("space_mailer.processed_join_request_email.accepted"))
        text = "[#{Site.current.name}] #{text}"
        mail.subject.should eql(text)
      }
      it("sets 'from'") { mail.from.should eql([Site.current.smtp_sender]) }
      it("sets 'headers'") { mail.headers.should eql({}) }
      it("sets 'reply_to'") { mail.reply_to.should eql([]) }
      it("assigns @space") { mail.body.encoded.should match(space.name) }
      it("assigns @join_request, @space and @action") {
        url = space_url(space, :host => Site.current.domain)
        content = I18n.t("space_mailer.processed_join_request_email.message.link.accepted",
                         :space => space.name,
                         :space_url => url)
        mail.body.encoded.should match(content)
      }
    end

    context "when the join request was rejected" do
      before { join_request.update_attributes(accepted: false) }
      it("sets 'subject'") {
        text = I18n.t("space_mailer.processed_join_request_email.subject",
                      :space => space.name,
                      :action => I18n.t("space_mailer.processed_join_request_email.rejected"))
        text = "[#{Site.current.name}] #{text}"
        mail.subject.should eql(text)
      }
      it("assigns @join_request, @space and @action") {
        url = space_url(space, :host => Site.current.domain)
        content = I18n.t("space_mailer.processed_join_request_email.message.link.rejected",
                         :space_url => url)
        mail.body.encoded.should match(content)
      }
      it("sends email to the join requests's introducer") {
        mail.to.should include(join_request.introducer.email)
      }
    end

    context "uses the candidate's locale" do
      before {
        Site.current.update_attributes(:locale => "en")
        introducer.update_attribute(:locale, "en")
        candidate.update_attribute(:locale, "pt-br")
      }
      it {
        action = I18n.t("space_mailer.processed_join_request_email.accepted", locale: "pt-br")
        content = I18n.t('space_mailer.processed_join_request_email.message.header', action: action,
                         space: space.name, locale: "pt-br")
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end

    context "uses the site's default locale if the candidate has no locale set" do
      before {
        introducer.update_attribute(:locale, "en")
        candidate.update_attribute(:locale, nil)
        Site.current.update_attributes(:locale => "pt-br")
      }
      it {
        action = I18n.t("space_mailer.processed_join_request_email.accepted", locale: "pt-br")
        content = I18n.t('space_mailer.processed_join_request_email.message.header', action: action,
                         space: space.name, locale: "pt-br")
        mail.body.encoded.should match(Regexp.escape(content))
      }
    end
  end

  context "calls the error handler on exceptions" do
    let(:exception) { Exception.new("test exception") }
    it {
      with_resque do
        BaseMailer.any_instance.stub(:render) { raise exception }
        Mconf::MailerErrorHandler.should_receive(:handle).with(SpaceMailer, nil, exception, "invitation_email", anything)
        SpaceMailer.invitation_email(join_request.id).deliver
      end
    }
  end
end
