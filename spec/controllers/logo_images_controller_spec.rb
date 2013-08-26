require 'spec_helper'

describe LogoImagesController do

  describe "GET 'crop'" do
    it "returns http success" do
      get 'crop'
      response.should be_success
    end
  end

end
