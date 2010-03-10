require 'openid/association'

class OpenIdAssociation < ActiveRecord::Base
  def from_record
    OpenID::Association.new(handle, secret, issued, lifetime, assoc_type)
  end
end

