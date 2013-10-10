require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        if params[:user] and params[:ldap_auth] and ldap_enabled?
          ldap_server = ldap_from_site
          ldap = ldap_connection(ldap_server)
          ldap.auth ldap_server.ldap_user, ldap_server.ldap_user_password
          # Tries to bind to the ldap server
          if ldap.bind
            # Tries to authenticate the user to the ldap server
            ldap_user = ldap.bind_as(:base => ldap_server.ldap_user_treebase, :filter => ldap_filter(ldap_server), :password => password)
            if ldap_user
              # Login or create the account
              user = login_or_create_user(ldap_user,ldap_server)
              # Says to devise that the user account was found and follow on with login
              success!(user)
              flash[:notice] = I18n.t('ldap.user.valid_login', :login => login)
            else
              fail(:invalid_login)
              flash[:error] = I18n.t('ldap.user.invalid_login')
            end
          else
            fail(:invalid_login)
            flash[:error] = I18n.t('ldap.server.invalid_bind')
          end
        elsif not ldap_enabled?
          fail(:invalid_login)
          flash[:error] = I18n.t('ldap.site.enabled')
        elsif not params[:ldap_auth]
          fail(:invalid_login)
        else
          fail(:invalid_login)
          flash[:error] = I18n.t('ldap.user.missing_login')
        end
      end

       # Returns the login provided by user 
      def login
        params[:user][:login]
      end

      # Returns the password provided by user
      def password
        params[:user][:password]
      end

      # Returns the current Site so we can get the ldap variables
      def ldap_from_site
        Site.current
      end

      # Returns the filter to bind the user
      def ldap_filter(ldap)
        Net::LDAP::Filter.eq(ldap.ldap_username_field, login)
      end

     # Returns true if the ldap is enabled in Mconf Portal
      def ldap_enabled?
        if ldap_from_site.ldap_enabled?
          return true
        else
          return false
        end
      end

      # Creates the ldap variable to connect to ldap server
      # port 636 means LDAPS, so whe use encryption (simple_tls)
      # else there is no security (usually port 389)
      def ldap_connection(ldap)
        if ldap.ldap_port == 636
          Net::LDAP.new(:host => ldap.ldap_host, :port => ldap.ldap_port, :encryption => :simple_tls)
        else
          Net::LDAP.new(:host => ldap.ldap_host, :port => ldap.ldap_port)
        end
      end

      # Login a ldap_user using his ldap information
      # or create the account if this is his first login
      # return the user (new or existing) 
      def login_or_create_user(ldap_user, ldap)
        # the fields that define the name and email are configurable in the Site model
        ldap_name = ldap_user.first[ldap.ldap_name_field].first if ldap_user.first[ldap.ldap_name_field] || ldap_user.first.cn
        ldap_email = ldap_user.first[ldap.ldap_email_field].first if ldap_user.first[ldap.ldap_email_field] || ldap_user.first.mail
        # uses the ldap email to check if the user already has an account
        token = find_or_create_token(ldap_email)
        token.user = create_account(ldap_email,ldap_name)
        token.save!
        token.user
      end

      # Searches for a LdapToken using the user email as identifier
      # Creates one token if none is found
      def find_or_create_token(id)
        token = LdapToken.find_by_identifier(id)
        token = create_token(id) if token.nil?
        token       
      end

      # Create the ldaptoken using the user email as identifier
      def create_token(id)
        LdapToken.create!(:identifier => id)
      end

      # Create the user account if there is no user with the email provided by ldap
      # Or returns the existing account with the email 
      def create_account(id,name)
        unless User.find_by_email(id)
          pw = SecureRandom.hex(16)
          user = User.create!(:username => name, :login => login, :email => id, :password => pw, :password_confirmation => pw, :_full_name => name)
          user.profile.update_attributes(:full_name => name)
          user.skip_confirmation!
          user
        else
          User.find_by_email(id)
        end
      end

    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
