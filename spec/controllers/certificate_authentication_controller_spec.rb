require 'spec_helper'

describe CertificateAuthenticationController do

  describe "#login" do
    it "signs in the user if the certificate is valid"
    it "creates a new user if it doesn't exist yet"
    it "uses an existent user if the certificate info matches the user"
    it "creates a new certificate token associated with the user"
    it "returns an error when the certificate is invalid"

    context "join webconference without creating a user" do
      before {
        Site.current.update_attributes(certificate_login_enabled: true)
        @cert_mock = double(Mconf::SSLClientCert)
        Mconf::SSLClientCert.stub(:new) { @cert_mock }
        @cert_mock.stub(:get_name) { "Test User Name" }
        @cert_mock.stub(:get_email) { "fake@mconf.org" }
      }

      it { expect { get :login, format: 'json', create: false }.not_to change{ User.count } }
    end
  end

  describe "#create_account?" do
    ['false', false].each do |value|
      it("returns false for #{value.inspect}") {
        controller.stub(:params).and_return({ create: value })
        controller.send(:create_account?).should be(false)
      }
    end

    ['true', true, 1, nil, 0, 'other'].each do |value|
      it("returns true for #{value.inspect}") {
        controller.stub(:params).and_return({ create: value })
        controller.send(:create_account?).should be(true)
      }
    end

    it("returns true when params is empty") {
      controller.stub(:params).and_return({})
      controller.send(:create_account?).should be(true)
    }
  end
end
