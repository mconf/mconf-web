# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

describe LogoImagesHelper do

  describe "#validate_logo_size" do
    @valid_sizes = ['32', '84x64', '128', '168x128', '300', '336x256']

    @valid_sizes.each do |size|
      it { validate_logo_size(size).should eq(size) }
    end

    # some invalid logo sizes
    it { validate_logo_size('').should eq('128') }
    it { validate_logo_size('0').should eq('128') }
    it { validate_logo_size('129').should eq('128') }
  end

  describe "#logo_initials" do
    let(:user) { FactoryGirl.create(:user) }
    let(:space) { FactoryGirl.create(:space) }

    it { logo_initials(user, size: '32').should eq(content_tag(:div, user.initials[0..1].upcase, class: "logo-initials #{logo_initials_class(user.name)}")) }
    it { logo_initials(user, size: '10').should eq(content_tag(:div, user.initials[0..1].upcase, class: "logo-initials #{logo_initials_class(user.name)}")) }
    it { logo_initials(space, size: '32').should eq(content_tag(:div, space.initials[0..1].upcase, class: "logo-initials #{logo_initials_class(space.name)}")) }
    it { logo_initials(space, size: '128').should eq(content_tag(:div, space.initials[0..1].upcase, class: "logo-initials #{logo_initials_class(space.name)}")) }
  end

  describe "#logo_image" do
    context "for a user" do
      it "adds an image tag with the logo of a user"
      it "if the user has no logo sets the default logo"
    end
    context "for a space" do
      it "adds an image tag with the logo of a space"
      it "if the space has no logo sets the default logo"
    end
  end

  describe "#link_logo_image" do
    it "adds the logo from #logo_image inside an <a>"
  end

  describe "#logo_image_removed" do
    it "adds the standard logo for some object that was removed"
  end

end
