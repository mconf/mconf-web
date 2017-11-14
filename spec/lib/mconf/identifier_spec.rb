# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe Mconf::Identifier do
  let(:target) { Mconf::Identifier }

  describe '#unique_mconf_id' do

    context "parameterizes the base value" do
      it { target.unique_mconf_id("My Name").should eql("my-name") }
      it { target.unique_mconf_id("another-name").should eql("another-name") }
      it { target.unique_mconf_id("My Name Wïth Chárs +1").should eql("my-name-with-chars-1") }
    end

    context "makes sure the id is unique among users" do
      before {
        FactoryGirl.create(:user, slug: "my-name")
        FactoryGirl.create(:user, slug: "my-name-2")
      }
      it { target.unique_mconf_id("My Name").should eql("my-name-3") }
    end

    context "makes sure the id is unique among spaces" do
      before {
        FactoryGirl.create(:space, slug: "my-name")
        FactoryGirl.create(:space, slug: "my-name-2")
      }
      it { target.unique_mconf_id("My Name").should eql("my-name-3") }
    end

    context "makes sure the id is unique among rooms" do
      before {
        FactoryGirl.create(:bigbluebutton_room, slug: "my-name")
        FactoryGirl.create(:bigbluebutton_room, slug: "my-name-2")
      }
      it { target.unique_mconf_id("My Name").should eql("my-name-3") }
    end

    context "makes sure the id is unique among users, spaces and rooms" do
      before {
        FactoryGirl.create(:user, slug: "my-name")
        FactoryGirl.create(:space, slug: "my-name-2")
        FactoryGirl.create(:bigbluebutton_room, slug: "my-name-3")
      }
      it { target.unique_mconf_id("My Name").should eql("my-name-4") }
    end

    it "considers blacklisted words" do
      file = File.join(::Rails.root, "config", "reserved_words.yml")
      words = YAML.load_file(file)['words']
      words.each do |word|
        target.unique_mconf_id(word).should eql("#{word}-2")
      end
    end

    context "ignores case when checking if it's unique" do
      before {
        FactoryGirl.create(:user, slug: "my-namE")
        FactoryGirl.create(:user, slug: "MY-Name-2")
      }
      it { target.unique_mconf_id("My Name").should eql("my-name-3") }
    end

    context "considers disabled and unapproved users and spaces" do
      before {
        FactoryGirl.create(:user, slug: "my-name")
        FactoryGirl.create(:user, slug: "my-name-2", disabled: true)
        FactoryGirl.create(:user, slug: "my-name-3", approved: false)
        FactoryGirl.create(:space, slug: "my-name-4")
        FactoryGirl.create(:space, slug: "my-name-5", disabled: true)
        FactoryGirl.create(:space, slug: "my-name-6", approved: false)
      }
      it { target.unique_mconf_id("My Name").should eql("my-name-7") }
    end

    context "returns nil if the base value informed is nil" do
      it { target.unique_mconf_id(nil).should be_nil }
    end

    context "returns nil if the base value informed is blank" do
      it { target.unique_mconf_id("  \t").should be_nil }
    end
  end
end
