require 'spec_helper'

describe LogoImagesHelper do

  describe "#logo_image" do
    context "for a user" do
      it "adds an image tag with the logo of a user"
      it "if size is > 32 uses the logo 128 for users"
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

end
