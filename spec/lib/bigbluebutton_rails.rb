# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe BigbluebuttonRails do

  describe "#invitation_url" do
    let(:target) { BigbluebuttonRails.configuration }
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }
    before {
      Site.current.update_attributes(domain: "localhost:4000")
    }

    it { target.should respond_to(:get_invitation_url) }
    it { target.get_invitation_url.should be_a(Proc) }
    it { target.get_invitation_url.call(room).should eql("http://#{Site.current.domain}/webconf/#{room.slug}") }

    context "works with HTTPS" do
      before {
        Site.current.update_attributes(ssl: true)
      }

      it { target.get_invitation_url.call(room).should eql("https://#{Site.current.domain}/webconf/#{room.slug}") }
    end
  end

  describe "#dynamic_metadata" do
    let(:target) { BigbluebuttonRails.configuration }
    let(:room) { FactoryGirl.create(:bigbluebutton_room) }
    before {
      Site.current.update_attributes(domain: "localhost:4000")
    }

    it { target.should respond_to(:get_dynamic_metadata) }
    it { target.get_dynamic_metadata.should be_a(Proc) }

    context "for a user room" do
      before {
        room.update_attributes(owner: FactoryGirl.create(:user))
      }

      it {
        expected = {
          "mconfweb-url" => "http://#{Site.current.domain}/",
          "mconfweb-room-type" => "User"
        }
        target.get_dynamic_metadata.call(room).should eql(expected)
      }
    end

    context "for a space room" do
      before {
        room.update_attributes(owner: FactoryGirl.create(:space))
      }

      it {
        expected = {
          "mconfweb-url" => "http://#{Site.current.domain}/",
          "mconfweb-room-type" => "Space"
        }
        target.get_dynamic_metadata.call(room).should eql(expected)
      }
    end

    context "works with HTTPS" do
      before {
        Site.current.update_attributes(ssl: true)
        room.update_attributes(owner: FactoryGirl.create(:space))
      }

      it {
        expected = {
          "mconfweb-url" => "https://#{Site.current.domain}/",
          "mconfweb-room-type" => "Space"
        }
        target.get_dynamic_metadata.call(room).should eql(expected)
      }
    end
  end
end
