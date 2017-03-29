require 'spec_helper'

describe CertificateAuthenticationController do

  context "login" do
    it "signs in the user if the certificate is valid"
    it "creates a new user if it doesn't exist yet"
    it "uses an existent user if the certificate info matches the user"
    it "creates a new certificate token associated with the user"
    it "returns an error when the certificate is invalid"
  end

  context "join webconference without creating a user" do
    before {
      Site.current.update_attributes(certificate_login_enabled: true)
      @cert_mock = double(Mconf::SSLClientCert)
      Mconf::SSLClientCert.stub(:new) { @cert_mock }
      @cert_mock.stub(:get_name) { "Test User Name" }
    }

    it { expect { get :login, format: 'json', join_only: true }.not_to change{ User.count } }
  end

end
