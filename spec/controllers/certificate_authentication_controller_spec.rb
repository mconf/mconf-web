require 'spec_helper'

describe CertificateAuthenticationController do

  context "login" do
    it "signs in the user if the certificate is valid"
    it "creates a new user if it doesn't exist yet"
    it "uses an existent user if the certificate info matches the user"
    it "creates a new certificate token associated with the user"
    it "returns an error when the certificate is invalid"
  end

end
