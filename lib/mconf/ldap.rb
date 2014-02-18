# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class LDAP

    # the root key used to store all the information in the session
    ENV_KEY = :ldap_data

    # `session` is the session object where the user information will be stored
    def initialize(session)
      @session = session
    end

    # Validates the data of a user received from LDAP
    def validate_user(ldap_user, ldap_configs)

      # get the username, full name and email from the data returned by the server
      username, email, name = user_info(ldap_user, ldap_configs)

      if username.blank?
        :username
      elsif email.blank?
        :email
      elsif name.blank?
        :name
      else
        nil
      end
    end

    # Creates the internal structures for the `ldap_user` using the ldap information
    # as configured in `ldap_configs`.
    def find_or_create_user(ldap_user, ldap_configs)
      Rails.logger.info "LDAP: finding or creating user"

      # get the username, full name and email from the data returned by the server
      username, email, name = user_info(ldap_user, ldap_configs)

      # creates the token and the internal account, if needed
      token = find_or_create_token(email)
      if token.nil?
        nil
      else
        token.user = create_account(email, username, name)
        if token.user && token.save
          token.user
        else
          nil
        end
      end
    end

    # Sets the user as signed in via LDAP in the session.
    def sign_user_in(user)
      @session[ENV_KEY] = { username: user.username, email: user.email }
    end

    # Returns whether the user is signed in via LDAP or not.
    def signed_in?
      !@session.nil? && @session.has_key?(ENV_KEY)
    end

    private

    # Searches for a LdapToken using the user email as identifier
    # Creates one token if none is found
    def find_or_create_token(id)
      id = id.to_s

      Rails.logger.info "LDAP: searching a token for email '#{id}'"
      token = LdapToken.find_by_identifier(id)
      if token
        Rails.logger.info "LDAP: there's already a token"
      else
        Rails.logger.info "LDAP: no token yet, creating one"
        token = LdapToken.create(:identifier => id)
        unless token.save
          Rails.logger.error "LDAP: could not create user token"
          Rails.logger.error "Errors: " + invalid.record.errors
          token = nil
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
      if user
        Rails.logger.info "LDAP: there's already a user with this id (#{id})"
      else
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
        unless user.save
          Rails.logger.error "LDAP: error while saving the user model"
          Rails.logger.error "Errors: " + user.errors.messages.join(", ")
          user = nil
        end
      end
      user
    end

    def user_info(ldap_user, ldap_configs)
      if ldap_user[ldap_configs.ldap_username_field]
        username = ldap_user[ldap_configs.ldap_username_field].first
      else
        username = ldap_user.uid
      end
      if ldap_user[ldap_configs.ldap_email_field]
        email = ldap_user[ldap_configs.ldap_email_field].first
      else
        email = ldap_user.mail
      end
      if ldap_user[ldap_configs.ldap_name_field]
        name = ldap_user[ldap_configs.ldap_name_field].first
      else
        name = ldap_user.cn
      end
      [username, email, name]
    end

  end
end
