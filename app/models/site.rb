# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

# Require Station Model
require_dependency "#{ Rails.root.to_s }/vendor/plugins/station/app/models/site"

class Site
  acts_as_stage

  def signature_in_html
    if signature
      return signature.gsub(/\r\n?/,'<br>')
    else
      return ""
    end
  end

  def xmpp_server
    XmppServer.current
  end

  # Delegate xmpp_server_password and xmpp_server_password_confirmation
  %w( password password_confirmation ).each do |a|
    eval <<-EOS
      def xmpp_server_#{ a }            # def xmpp_server_password
        xmpp_server.#{ a }              #   xmpp_server.password
      end                               # end
      
      def xmpp_server_#{ a }=(value)    # def xmpp_server_password=(value)
        xmpp_server.#{ a } = value      #   xmpp_server.password = value
      end                               # end
    EOS
  end

  validates_associated :xmpp_server,
                       :if => Proc.new{ |site| site.xmpp_server_password.present? },
                       :message => I18n.t('xmpp_server.password_invalid')

  after_save :save_xmpp_server
  after_save :reload_cm_classes

  private

  def save_xmpp_server
    xmpp_server.save! if xmpp_server.password.present? && xmpp_server.__send__(:password_not_saved?)
  end
  
  def reload_cm_classes
    ConferenceManager::Resource.reload
  end
end
