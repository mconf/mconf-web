require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable

      def valid?
         ldap_enabled?
      end

      def authenticate!
        if ldap_enabled? and params[:user]
          Rails.logger.info "LDAP: LDAP is enabled, trying to connect to LDAP server"
          configs = ldap_configs
          ldap = ldap_connection(configs)
          ldap.auth configs.ldap_user, configs.ldap_user_password

          # Tries to bind to the ldap server
            if ldap_bind(ldap)
              Rails.logger.info "LDAP: bind of the configured user was successful"
              Rails.logger.info "LDAP: trying to bind the target user: '#{login_from_params}'"

              # Tries to authenticate the user to the ldap server
              Rails.logger.info "ldapFilter: " + ldap_filter(configs).inspect
              Rails.logger.info "ldapConfigs: " + configs.inspect
              ldap_user = ldap.bind_as(:base => configs.ldap_user_treebase, :filter => ldap_filter(configs), :password => password_from_params)
              if ldap_user
                Rails.logger.info "LDAP: user successfully authenticated: #{ldap_user}"

                # validate the ldap_user from LDAP server
                validate_ldap_user(ldap_user.first, configs)

                # login or create the account
                user = find_or_create_user(ldap_user.first, configs)
                success!(user)
              else
                Rails.logger.error "LDAP: authentication failed, response: #{ldap_user}"
                Rails.logger.error "LDAP: error code: #{ldap.get_operation_result.code}"
                Rails.logger.error "LDAP: error message: #{ldap.get_operation_result.message}"
                fail(:invalid)
              end
            end

        # LDAP is not enabled in the site
        elsif not ldap_enabled?
          Rails.logger.info "LDAP: authentication is not enabled, exiting LDAP authentication strategy"
          fail(I18n.t('devise.strategies.ldap_authenticatable.ldap_not_enabled'))
        else
          Rails.logger.info "LDAP: invalid user credentials"
          fail(:invalid)
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
          Net::LDAP.new(:host => configs.ldap_host, :port => configs.ldap_port, :timeout => 10, :encryption => :simple_tls)
        else
          Net::LDAP.new(:host => configs.ldap_host, :port => configs.ldap_port, :timeout => 10)
        end
      end

      # Do the ldap server bind - treats connection timeout
      def ldap_bind(ldap)
        begin
        Timeout::timeout(10) do
          if ldap.bind
            Rails.logger.info "LDAP: succesfully binded to the LDAP server" 
            true
          else
            Rails.logger.error "LDAP: could not bind the configured user, check your configurations"
            Rails.logger.error "LDAP: error code: #{ldap.get_operation_result.code}"
            Rails.logger.error "LDAP: error message: #{ldap.get_operation_result.message}"
            fail!(I18n.t('devise.strategies.ldap_authenticatable.invalid_bind'))
          end
        end
        rescue Timeout::Error => e
          Rails.logger.error "LDAP: the server did not respond, error: #{e}"
          fail!(I18n.t('devise.strategies.ldap_authenticatable.invalid_bind'))
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
          begin
          token = LdapToken.create!(:identifier => id)
          rescue ActiveRecord::RecordInvalid => invalid
            Rails.logger.error "LDAP: could not create user token"
            Rails.logger.error "Errors: " + invalid.record.errors
            fail!(I18n.t('devise.strategies.ldap_authenticatable.invalid_token'))
          end
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
          if not user.save
            Rails.logger.error "LDAP: error while saving the user model"
            Rails.logger.error "Errors: " + user.errors.messages.join(", ")
            fail!(I18n.t('devise.strategies.ldap_authenticatable.invalid_user'))
          end
        end
        user
      end

      # Validate the ldap_user data
      def validate_ldap_user(ldap_user, ldap_configs)

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

        if ldap_username.nil? or ldap_username.to_s.eql?("")
          Rails.logger.error "LDAP: the username from ldap_user is empty"
          fail!(I18n.t('devise.strategies.ldap_authenticatable.missing_username'))
        end
        if ldap_name.nil? or ldap_name.to_s.eql?("")
          Rails.logger.error "LDAP: the name from ldap_user is empty"
          fail!(I18n.t('devise.strategies.ldap_authenticatable.missing_name'))
        end
        if ldap_email.nil? or ldap_email.to_s.eql?("")
          Rails.logger.error "LDAP: the email from ldap_user is empty"
          fail!(I18n.t('devise.strategies.ldap_authenticatable.missing_email'))
        end
        true
      end

    end
  end
end

 Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
