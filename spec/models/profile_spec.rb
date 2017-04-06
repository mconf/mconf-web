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

  describe "#first_names" do
    context 'returns the first name if is longer than min length' do
      let(:profile) { FactoryGirl.create(:profile, full_name: 'Richard Bawlins') }
      it { profile.first_names(5).should eq('Richard') }
    end

    context 'returns more than one name if the first are shorter than min length' do
      let(:profile) { FactoryGirl.create(:profile, full_name: 'A Mr. Dawn of the Night') }
      it { profile.first_names(6).should eq('A Mr. Dawn') }
    end

    context "returns the entire first name even if it's a lot longer than min length" do
      let(:profile) { FactoryGirl.create(:profile, full_name: 'Mesopopoulousnacious Ternaris') }
      it { profile.first_names(2).should eq('Mesopopoulousnacious') }
    end

    context "uses 5 as the default min length" do
      it { FactoryGirl.create(:profile, full_name: 'Marko C').first_names.should eq('Marko') }
      it { FactoryGirl.create(:profile, full_name: 'M C Donna').first_names.should eq('M C Donna') }
      it { FactoryGirl.create(:profile, full_name: 'M C D O').first_names.should eq('M C D') }
    end
  end

  context "after_update" do
    let(:user) { FactoryGirl.create(:user) }
    let(:profile) { user.profile }

    context "updates the name of the user's web conference room if both were equal" do
      before(:each) {
        profile.update_attributes(full_name: "name before")
        profile.user.bigbluebutton_room.update_attribute(:name, "name before")
        profile.update_attributes(full_name: "name after")
      }

      it { profile.user.bigbluebutton_room.name.should eq("name after") }
    end

    context "does not update the name of the user's web conference room if both were different" do
      before(:each) {
        profile.update_attributes(full_name: "name before")
        profile.user.bigbluebutton_room.update_attribute(:name, "other name")
        profile.update_attributes(full_name: "name after")
      }

      it { profile.user.bigbluebutton_room.name.should eq("other name") }
    end
  end

end
