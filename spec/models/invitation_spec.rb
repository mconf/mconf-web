# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Invitation do

  describe ".url_with_protocol" do
    let(:invitation) { FactoryGirl.create(:invitation, url: url) }

    context "a site with ssl enabled" do
      before { Site.current.update_attributes(ssl: true) }

      context "with an http url" do
        let(:url) { 'http://cygnusbook.to' }

        it { invitation.url.should eq(url) }
        it { invitation.url_with_protocol.should eq('https://cygnusbook.to') }
      end

      context "with an https url" do
        let(:url) { 'https://hemisphere.es' }

        it { invitation.url.should eq(url) }
        it { invitation.url_with_protocol.should eq('https://hemisphere.es') }
      end

      context "with an invalid url just return it" do
        let(:url) { 'https://the trees' }

        it { invitation.url.should eq(url) }
        it { invitation.url_with_protocol.should eq(url) }
      end

    end

    context "a site with ssl disabled" do
      before { Site.current.update_attributes(ssl: false) }

      context "with an http url" do
        let(:url) { 'http://cygnusbook.to' }

        it { invitation.url.should eq(url) }
        it { invitation.url_with_protocol.should eq('http://cygnusbook.to') }
      end

      context "with an https url" do
        let(:url) { 'https://hemisphere.es' }

        it { invitation.url.should eq(url) }
        it { invitation.url_with_protocol.should eq('http://hemisphere.es') }
      end

      context "with an invalid url just return it" do
        let(:url) { 'https://the trees' }

        it { invitation.url.should eq(url) }
        it { invitation.url_with_protocol.should eq(url) }
      end
    end
  end

  describe ".create_invitations" do
    it "creates an invitation for each user in the list"
    it "uses the params passed as arguments"
    it "if the recipient exists in the database, sets recipient and not recipient_email"
    it "if the recipient does not exist in the database, sets recipient_email and not recipient"

    describe "doesn't carry the param recipient or recipient_email from one user to the next" do
      let!(:user) { FactoryGirl.create(:user) }
      before { Invitation.create_invitations("anyone@mconf.org, #{user.id}, other@mconf.org", {}) }
      it { Invitation.first.recipient.should be_nil }
      it { Invitation.first.recipient_email.should eql("anyone@mconf.org") }
      it { Invitation.second.recipient.should eql(user) }
      it { Invitation.second.recipient_email.should be_nil }
      it { Invitation.last.recipient.should be_nil }
      it { Invitation.last.recipient_email.should eql("other@mconf.org") }
    end
  end

  describe "#set_end_from_duration" do
    let(:target) { FactoryGirl.create(:invitation, ends_on: nil, starts_on: nil, duration: nil) }

    context "if everything is nil" do
      before { target.set_end_from_duration }
      it { target.ends_on.should be_nil }
    end

    context "if starts_on is nil" do
      before {
        target.update_attributes(duration: 60)
      }
      it { target.ends_on.should be_nil }
    end

    context "if duration is nil" do
      before {
        target.update_attributes(starts_on: DateTime.now)
      }
      it { target.ends_on.should be_nil }
    end

    context "if there's already an ends_on set" do
      let(:ends_on) { DateTime.now + 5.hours }
      before {
        target.update_attributes(starts_on: DateTime.now, duration: 60, ends_on: ends_on)
      }
      it { target.ends_on.should eql(ends_on) }
    end

    context "no ends_on and has starts_on and duration" do
      let(:now) { DateTime.now }
      before {
        target.update_attributes(starts_on: now, duration: 60*60)
      }
      it { target.ends_on.should eql(now + 1.hour) }
    end
  end

  describe "#has_duration?" do
    it { FactoryGirl.create(:invitation, duration: nil).has_duration?.should be(false) }
    it { FactoryGirl.create(:invitation, duration: 0).has_duration?.should be(false) }
    it { FactoryGirl.create(:invitation, duration: 1).has_duration?.should be(true) }
    it { FactoryGirl.create(:invitation, duration: 9999).has_duration?.should be(true) }
  end
end
