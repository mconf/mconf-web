# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Mconf
  class Shibboleth

    # the key used to indicate in the session if the user is signed in
    # via shibboleth or not
    SESSION_KEY = :shib_login

    # `session` is the session object where the user information will be stored
    def initialize(session)
      # Data will hold the shibolleth data read from the environment
      @data = {}

      # This holds the session data, but will only write a boolean value to it
      # denoting whether the user has logged in via shibboleth
      @session = session
    end

    # Loads the information from the environment variables `env_variables` into
    # the object. Uses `filters` to know which variables should be stored and which
    # should be ignored.
    # `filters` is a string with one or more filters separated by '\n' or '\r\n'.
    # The filters can be a simple string or a string in the format of a regex.
    # e.g. `email\nshib-.*\r\nuid`: will get the variables that match /^email$/,
    #   /^shib-.*$/, and /^uid$/
    # If `filters` is blank, will use the default filter /^shib-/
    def load_data(env_variables, filters='')
      filter = split_into_regexes(filters)
      filter = [/^shib-/] if filter.empty?

      shib_data = {}
      env_variables.each do |key, value|
        unless filter.select{ |f| key.to_s.downcase =~ f }.empty?
          value.force_encoding('UTF-8') if value.present? # see #1774
          shib_data[key.to_s] = value
        end
      end
      # Saves data sent by the shib server
      @data ||= {}
      @data.merge!(shib_data)

      Rails.logger.info "Shibboleth: user info loaded as: #{@data.inspect}"
      shib_data
    end

    # Returns whether the basic information needed for a user to login is present
    # in the session or not.
    def has_basic_info
      !!(@data && get_identifier && get_email && get_name && get_principal_name)
    end

    def get_field(field)
      result = @data[field]
      result = result.dup unless result.blank?
      result
    end

    # The name of the field to be used as the identifier for users signed in via Shibboleth.
    # By default it currently uses the the EPPN.
    def get_identifier
      get_principal_name
    end

    # Returns the email stored, if any.
    def get_email
      get_field Site.current.shib_email_field
    end

    # Returns the name of the user stored, if any.
    def get_name
      get_field Site.current.shib_name_field
    end

    # Returns the "principalName" attribute, that represents the user's unique identifier in
    # the federation.
    def get_principal_name
      get_field Site.current.shib_principal_name_field
    end

    # Returns the login of the user, if any.
    def get_login
      get_field(Site.current.shib_login_field) || get_name # uses the name by default
    end

    # Returns an unique login according to the login stored in the object.
    # If there's no login, returns nil. Otherwise will always
    # return a login that doesn't exist yet.
    def get_unique_login
      Mconf::Identifier.unique_mconf_id(get_login)
    end

    # Returns the shibboleth provider of the user, if any.
    def get_identity_provider
      get_field 'Shib-Identity-Provider'
    end

    # Returns all the shibboleth data stored in the session.
    def get_data
      @data.try(:dup)
    end

    # Sets the shibboleth data, without processing the input hash
    # Used when reading saved user data from the session or database
    def set_data(data)
      @data = data
    end

    # Returns whether the user is signed in via federation or not.
    # Does it by reading the session data passed in to the constructor
    def signed_in?
      !@session.nil? && @session.has_key?(SESSION_KEY)
    end

    # Mark in the session that the user signed in via Shibboleth and
    # set the current time user signed in
    def set_signed_in(user, token)
      user.signed_in_via_external = true
      @session[SESSION_KEY] = true
      token.current_sign_in_at = Time.now.utc
      token.save
    end

    # Returns the name of the attributes used to get the basic user information from the
    # session. Returns and array with [ <attribute for email>, <attribute for name> ]
    def basic_info_fields
      [ Site.current.shib_email_field,
        Site.current.shib_name_field,
        Site.current.shib_principal_name_field ]
    end

    # Finds the ShibToken associated with the user whose information is stored in the object.
    def find_token
      ShibToken.find_by_identifier(get_identifier)
    end

    # Finds the ShibToken and updates it with the information in the object, unless
    # it's empty. Returns the token.
    # Doesn't raise an exception if it fails to save the token, will return the
    # errors in the model.
    def find_and_update_token
      token = find_token
      if token.present? && !get_data.blank?
        token.data = get_data
        token.save
      end
      token
    end

    # Searches for a ShibToken using data in the object and returns it. Creates a new
    # ShibToken if no token is found and returns it.
    def find_or_create_token
      token = find_token
      token = create_token(get_identifier) if token.nil?
      token
    end

    # Creates a new user using the information stored in the session.
    # Returns the User created after calling `save`. This might have errors if the call to
    # `save` failed.
    # The shib_token parameter is used as the Owner of the RecentActivity.
    # Expects that at least the email and name are set!
    def create_user(shib_token)
      password = SecureRandom.hex(16)
      params = {
        username: get_unique_login, email: get_email,
        password: password, password_confirmation: password,
        profile_attributes: {
          full_name: get_name
        }
      }

      user = User.new params
      user.skip_confirmation!
      if !user.save
        Rails.logger.error "Shibboleth: error while saving the user model"
        Rails.logger.error "Shibboleth: errors: " + user.errors.full_messages.join(", ")
      end

      user
    end

    # Update data in the user model which might change in the federation, for now
    # the only fields used are 'email' and 'name'
    def update_user(token)
      user = token.user

      # Don't update anything if it's an associated account
      if token.new_account?
        user.update_attributes(email: get_email)
        user.skip_confirmation_notification!
        user.confirm
        user.profile.update_attributes(full_name: get_name)
      end
    end

    def create_notification(user, token)
      RecentActivity.create(
        key: 'shibboleth.user.created', owner: token, trackable: user, notified: false
      )
    end

    private

    # Splits a string `value` into several RegExps. Breaks the string at every
    # '\n' and puts all strings (VALUE) into a regex in the format /^VALUE$/.
    def split_into_regexes(value)
      unless value.blank?
        cloned = value.clone
        cloned = cloned.split(/\r?\n/).map{ |s| s.strip.downcase }
        cloned.map{ |v| Regexp.new("^#{v}$", "i") }
      else
        []
      end
    end

    def create_token(id)
      ShibToken.new(identifier: id)
    end

  end
end
