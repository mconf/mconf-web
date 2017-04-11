# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class LDAP

    # the root key used to store all the information in the session
    SESSION_KEY = :ldap_data

    def initialize(session = {})
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
        token.user = find_account(email)
        token.data = data_from_entry(ldap_user)
        if token.user
          Rails.logger.info "LDAP: there's already a user with this id (#{email})"
        else
          Rails.logger.info "LDAP: creating a new account for email '#{email}', username '#{username}', full name: '#{name}'"
          token.user = create_account(email, username, name, token)
          token.new_account = true # account created by LDAP
        end
        if token.user && token.save
          token.user
        else
          nil
        end
      end
    end

    # Sets the user as signed in via LDAP in the session.
    def set_signed_in(user, token)
      user.signed_in_via_external = true
      @session[SESSION_KEY] = { username: user.username, email: user.email }
      token.current_sign_in_at = Time.now.utc
      token.save
    end

    # Returns whether the user is signed in via LDAP or not.
    def signed_in?
      !@session.nil? && @session.has_key?(SESSION_KEY)
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

    def find_account(id)
      User.where('lower(email) = ?', id.downcase).first
    end

    # Create the user account if there is no user with the email provided by ldap
    # Or returns the existing account with the email
    def create_account(id, username, full_name, ldap_token)
      # we need this to make sure the values are strings and not string-like objects
      # returned by LDAP, otherwise the user creation might fail
      id = id.to_s
      username = username.to_s
      full_name = full_name.to_s

      password = SecureRandom.hex(16)
      params = {
        username: get_unique_login(username),
        email: id,
        password: password,
        password_confirmation: password
      }
      user = User.new(params)
      user.profile.full_name = full_name
      user.skip_confirmation!
      if user.save
        create_notification(user, ldap_token)
      else
        Rails.logger.error "LDAP: error while saving the user model"
        Rails.logger.error "LDAP: errors: " + user.errors.full_messages.join(", ")
        user = nil
      end
      user
    end

    def user_info(ldap_user, ldap_configs)
      if ldap_user[ldap_configs.ldap_username_field] && !ldap_user[ldap_configs.ldap_username_field].empty?
        username = ldap_user[ldap_configs.ldap_username_field].first
      else
        username = ldap_user['uid'].first
      end
      username.gsub!(/@[^@]+$/, '') unless username.nil? # use only the first part if this is an email
      if ldap_user[ldap_configs.ldap_email_field] && !ldap_user[ldap_configs.ldap_email_field].empty?
        email = ldap_user[ldap_configs.ldap_email_field].first
      else
        email = ldap_user['mail'].first
      end
      if ldap_user[ldap_configs.ldap_name_field] && !ldap_user[ldap_configs.ldap_name_field].empty?
        name = ldap_user[ldap_configs.ldap_name_field].first
      else
        name = ldap_user['cn'].first
      end
      [username, email, name]
    end

    def data_from_entry ldap_entry
      data = {}
      ldap_entry.each { |k, v| data[k] = v }
      data
    end

    def create_notification(user, token)
      RecentActivity.create(
        key: 'ldap.user.created', owner: token, trackable: user, notified: false
      )
    end

    # Returns an unique login according to the base login returned by LDAP.
    # If there's no base login, returns nil. Otherwise will always return
    # a login that doesn't exist yet.
    def get_unique_login(base)
      Mconf::Identifier.unique_mconf_id(base)
    end

  end
end
