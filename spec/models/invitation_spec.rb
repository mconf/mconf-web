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

end
