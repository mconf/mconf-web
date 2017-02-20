# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Based on https://gist.github.com/3729390/

require 'abilities/base_ability'
require 'abilities/anonymous_ability'
require 'abilities/member_ability'
require 'abilities/superuser_ability'

require './lib/mconf/attribute_certificate'

module Abilities

  def self.ability_for(user)
    ac_conf = AttributeCertificateConfiguration.first
    use_certificates = ac_conf.try(:enabled?)

    # Try superuser via certificate and then via normal method
    if user && (use_certificates && Mconf::AttributeCertificate::role_for?(user, 'Global Admin') || user.superuser?)
    #if user and user.superuser?
      SuperUserAbility.new(user)
    elsif user && !user.anonymous?
      MemberAbility.new(user)
    else
      AnonymousAbility.new
    end
  end

end
