# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'spec_helper'

def certificate_list
  h = {}
  %w{ client1.crt client2.crt client3.crt }.each { |cert| h[cert] = IO.read("./spec/fixtures/files/certificates/#{cert}") }
  h
end

def error_certificate_list
  h = {}
  %w{ client-error.crt }.each { |cert| h[cert] = IO.read("./spec/fixtures/files/certificates/#{cert}") }
  h
end

describe Mconf::SSLClientCert do

  before do
    Site.current.update_attributes(certificate_login_enabled: true)
  end

  context "reading certificates" do
    certificate_list.each do |name, cert_str|
      context "test if '#{name}' is valid" do
        let(:cert) { Mconf::SSLClientCert.new(cert_str) }
        before { cert.create_user }

        it { cert.error.should be_nil }
        it { cert.certificate.class.should be(OpenSSL::X509::Certificate) }
        it { cert.user.should_not be_nil }
        it { cert.user.should be_valid }
      end
    end

    error_certificate_list.each do |name, cert_str|
      context "test if '#{name}' is invalid" do
        let(:cert) { Mconf::SSLClientCert.new(cert_str) }

        it { cert.error.should be(:certificate) }
        it { cert.certificate.should be_nil }
        it { cert.user.should be_nil }
      end
    end
  end

end
