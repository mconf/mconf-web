# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require "spec_helper"

describe Profile do

  it { should respond_to(:logo_image) }
  it { should respond_to(:crop_x) }
  it { should respond_to(:"crop_x=") }
  it { should respond_to(:crop_y) }
  it { should respond_to(:"crop_y=") }
  it { should respond_to(:crop_w) }
  it { should respond_to(:"crop_w=") }
  it { should respond_to(:crop_h) }
  it { should respond_to(:"crop_h=") }
  it { should respond_to(:crop_img_w) }
  it { should respond_to(:"crop_img_w=") }
  it { should respond_to(:crop_img_h) }
  it { should respond_to(:"crop_img_h=") }

  context "after_update" do
    let(:user) { FactoryGirl.create(:user) }
    let(:profile) { user.profile }

    it("calls #update_webconf_room") {
      profile.should_receive(:update_webconf_room)
      profile.update_attributes(full_name: "New Name")
    }
  end

  describe "#update_webconf_room" do
    let(:user) { FactoryGirl.create(:user) }
    let(:profile) { user.profile }

    context "updates the name" do
      before(:each) {
        profile.update_attributes(full_name: "Old Name")
        profile.update_attributes(full_name: "New Name")
      }
      it { profile.full_name.should eql("New Name") }
      it { user.bigbluebutton_room.name.should eql("New Name") }
    end

    context "doesn't update the name if the name was already changed directly before" do
      before(:each) {
        profile.update_attributes(full_name: "Old Name")
        user.bigbluebutton_room.update_attributes(name: "Custom Room Name")
        profile.update_attributes(full_name: "New Name")
      }
      it { profile.full_name.should eql("New Name") }
      it { user.bigbluebutton_room.name.should eql("Custom Room Name") }
    end
  end

  describe "#linkable_url" do
    let(:profile) { FactoryGirl.create(:profile) }

    context "an url without http://" do
      before { profile.update_attributes(url: 'mconf.org') }
      it { profile.linkable_url.should eql('http://mconf.org') }
    end

    context "an url with http://" do
      before { profile.update_attributes(url: 'http://mconf.org') }
      it { profile.linkable_url.should eql('http://mconf.org') }
    end

    context "an url with https://" do
      before { profile.update_attributes(url: 'https://mconf.org') }
      it { profile.linkable_url.should eql('https://mconf.org') }
    end

    context "a nil url" do
      before { profile.update_attributes(url: nil) }
      it { profile.linkable_url.should be_nil }
    end

    context "a blank url" do
      before { profile.update_attributes(url: '') }
      it { profile.linkable_url.should be_nil }
    end
  end

  describe "#first_name" do
    context 'returns the first name if is longer than min length' do
      let(:profile) { FactoryGirl.create(:profile, full_name: 'Richard Bawlins') }
      it { profile.first_name(5).should eq('Richard') }
    end

    context 'returns more than one name if the first are shorter than min length' do
      let(:profile) { FactoryGirl.create(:profile, full_name: 'A Mr. Dawn of the Night') }
      it { profile.first_name(6).should eq('A Mr. Dawn') }
    end

    context "returns the entire first name even if it's a lot longer than min length" do
      let(:profile) { FactoryGirl.create(:profile, full_name: 'Mesopopoulousnacious Ternaris') }
      it { profile.first_name(2).should eq('Mesopopoulousnacious') }
    end

    context "uses 4 as the default min length" do
      it { FactoryGirl.create(:profile, full_name: 'Mark C').first_name.should eq('Mark') }
      it { FactoryGirl.create(:profile, full_name: 'M C Donna').first_name.should eq('M C Donna') }
      it { FactoryGirl.create(:profile, full_name: 'M C D O').first_name.should eq('M C D') }
      it { FactoryGirl.create(:profile, full_name: 'Alan Dean').first_name.should eq('Alan') }
      it { FactoryGirl.create(:profile, full_name: 'Ana Paula').first_name.should eq('Ana Paula') }
    end
  end

  describe "#valid_url?" do
    it { FactoryGirl.build(:profile, url: nil).valid_url?.should be(false) }
    it { FactoryGirl.build(:profile, url: "").valid_url?.should be(false) }
    it { FactoryGirl.build(:profile, url: "   ").valid_url?.should be(false) }
    it { FactoryGirl.build(:profile, url: "http://").valid_url?.should be(false) }
    it { FactoryGirl.build(:profile, url: "https://").valid_url?.should be(false) }
    it { FactoryGirl.build(:profile, url: "lala@gmail.com").valid_url?.should be(false) }
    it { FactoryGirl.build(:profile, url: "https://mconf.org").valid_url?.should be(true) }
  end
end
