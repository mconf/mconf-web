# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module CertificateAuthenticationHelper

  def certificate_auth_link(text=nil, create=true)
    link_to certificate_login_path(format: 'json', create: create), class: 'certificate-auth-trigger' do
      if block_given?
        yield
      else
        text
      end
    end
  end

end
