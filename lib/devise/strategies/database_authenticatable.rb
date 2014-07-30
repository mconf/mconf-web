require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class DatabaseAuthenticatable < Authenticatable
      # Check when devise version changes
      def authenticate!
        resource = valid_password? && mapping.to.find_for_database_authentication(authentication_hash)
        user = User.find_for_authentication(:login => params[:user][:login])
        return fail(:not_found_in_database) unless resource && (Site.current.local_auth_enabled? || user.superuser)

        if validate(resource){ resource.valid_password?(password) }
          resource.after_database_authentication
          success!(resource)
        end
      end
    end
  end
end

Warden::Strategies.add(:database_authenticatable, Devise::Strategies::DatabaseAuthenticatable)
