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
end
