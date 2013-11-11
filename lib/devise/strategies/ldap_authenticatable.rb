require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable

      def valid?
        params[:ldap_auth]
      end

      def authenticate!
        if ldap_enabled? and params[:user]
          Rails.logger.info "LDAP: authenticating a user"

          configs = ldap_configs
          ldap = ldap_connection(configs)
          ldap.auth configs.ldap_user, configs.ldap_user_password

          # Tries to bind to the ldap server
          if ldap.bind
            Rails.logger.info "LDAP: bind of the configured user was successful"
            Rails.logger.info "LDAP: trying to bind the target user: '#{login_from_params}'"

            # Tries to authenticate the user to the ldap server
            ldap_user = ldap.bind_as(:base => configs.ldap_user_treebase, :filter => ldap_filter(configs), :password => password_from_params)
            if ldap_user
              Rails.logger.info "LDAP: user successfully authenticated: #{ldap_user}"

              # TODO: verify if the ldap_user has the attributes we need, otherwise return an error

              # login or create the account
              user = find_or_create_user(ldap_user.first, configs)

              # TODO: if user model has errors, show them to the user here

              success!(user)
            else
              Rails.logger.error "LDAP: authentication failed, response: #{ldap_user}"
              fail!(:invalid)
            end
          else
            Rails.logger.error "LDAP: could not bind the configured user, check your configurations"
            fail!(I18n.t('devise.strategies.ldap_authenticatable.invalid_bind'))
          end

        # ldap is not enable in the site
        elsif not ldap_enabled?
          fail!(I18n.t('devise.strategies.ldap_authenticatable.ldap_not_enabled'))

        else
          fail!(:invalid)
        end
      end

      # Returns the login provided by user
      def login_from_params
        params[:user][:login]
      end

      # Returns the password provided by user
      def password_from_params
        params[:user][:password]
      end

      # Returns the model that stores the configurations for LDAP
      def ldap_configs
        Site.current
      end

      # Returns the filter to bind the user
      def ldap_filter(ldap)
        Net::LDAP::Filter.eq(ldap.ldap_username_field, login_from_params)
      end

     # Returns true if the ldap is enabled in Mconf Portal
      def ldap_enabled?
        ldap_configs.ldap_enabled?
      end

      # Creates the ldap variable to connect to ldap server.
      # Port 636 means LDAPS, so whe use encryption (simple_tls).
      # Otherwise there is no security (usually port 389).
      def ldap_connection(configs)
        if configs.ldap_port == 636
          Net::LDAP.new(:host => configs.ldap_host, :port => configs.ldap_port, :encryption => :simple_tls)
        else
          Net::LDAP.new(:host => configs.ldap_host, :port => configs.ldap_port)
        end
      end

      # Creates the internal structures for the `ldap_user` using the ldap information
      # as configured in `ldap_configs`.
      def find_or_create_user(ldap_user, ldap_configs)
        Rails.logger.info "LDAP: finding or creating user"

        # get the username, full name and email from the data returned by the server
        if ldap_user[ldap_configs.ldap_username_field]
          ldap_username = ldap_user[ldap_configs.ldap_username_field].first
        else
          ldap_username = ldap_user.uid
        end
        if ldap_user[ldap_configs.ldap_name_field]
          ldap_name = ldap_user[ldap_configs.ldap_name_field].first
        else
          ldap_name = ldap_user.cn
        end
        if ldap_user[ldap_configs.ldap_email_field]
          ldap_email = ldap_user[ldap_configs.ldap_email_field].first
        else
          ldap_email = ldap_user.mail
        end

        # creates the token and the internal account, if needed
        token = find_or_create_token(ldap_email)
        token.user = create_account(ldap_email, ldap_username, ldap_name)
        token.save!
        token.user
      end

      # Searches for a LdapToken using the user email as identifier
      # Creates one token if none is found
      def find_or_create_token(id)
        id = id.to_s

        Rails.logger.info "LDAP: searching a token for email '#{id}'"
        token = LdapToken.find_by_identifier(id)
        if token.nil?
          Rails.logger.info "LDAP: no token yet, creating one"
          token = LdapToken.create!(:identifier => id)
        end
        token
      end

      # Create the user account if there is no user with the email provided by ldap
      # Or returns the existing account with the email
      def create_account(id, username, full_name)
        # we need this to make sure the values are strings and not string-like objects
        # returned by LDAP, otherwise the user creation might fail
        id = id.to_s
        username = username.to_s
        full_name = full_name.to_s

        user = User.find_by_email(id)
        unless user
          Rails.logger.info "LDAP: creating a new account for email '#{id}', username '#{username}', full name: '#{full_name}'"
          password = SecureRandom.hex(16)
          params = {
            :username => username.parameterize,
            :email => id,
            :password => password,
            :password_confirmation => password,
            :_full_name => full_name
          }
          user = User.new(params)
          user.skip_confirmation!
          user.save
        end
        user
      end

    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
