# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Filters added to this controller apply to all controllers in the application.
# Likewse, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include PublicActivity::StoreController # to automatically track recent activity
  include Mconf::LocaleControllerModule

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery with: :exception

  before_filter :set_current_locale # Locale as param
  before_filter :set_time_zone
  before_filter :store_location

  helper_method :current_site
  helper_method :previous_path_or
  helper_method :locale_i18n

  # Handle errors - error pages
  rescue_from Exception, :with => :render_500
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  rescue_from ActionController::UnknownController, :with => :render_404
  rescue_from ActionController::RoutingError, :with => :render_404
  rescue_from ::AbstractController::ActionNotFound, :with => :render_404
  rescue_from CanCan::AccessDenied, with: :handle_access_denied

  rescue_from ActionController::InvalidCrossOriginRequest, with: :render_400
  rescue_from ActionController::UnknownFormat, with: :render_404

  # Code that to DRY out permitted param filtering
  # The controller declares allow_params_for :model_name and defines allowed_params
  def self.allow_params_for instance_name
    instance_name ||= controller_name.singularize.to_sym

    define_method("#{instance_name}_params") do
      unless params[instance_name].blank?
        params[instance_name].permit(*allowed_params)
      else
        {}
      end
    end
  end

  # Add some stack trace info to production log
  def log_stack_trace exception
    Rails.logger.info "#{exception.class.name} (#{exception.message}):"
    st = "  " + exception.backtrace.first(15).join("\n  ")
    Rails.logger.info st
  end

  # Splits a comma separated list of emails into a list of emails without trailing spaces
  def split_emails email_string
    email_string.split(/[\s,;]/).select { |e| !e.empty? }
  end

  def valid_email? email
    require 'valid_email'
    ValidateEmail.valid?(email)
  end

  def current_ability
    @current_ability ||= Abilities.ability_for(current_user)
  end

  # Returns the current site. Prefer this method over `Site.current` when calling from
  # views, since it caches the object.
  def current_site
    @current_site ||= Site.current
  end

  # Where to redirect to after sign in with Devise
  def after_sign_in_path_for(resource)
    if !params["return_to"].blank? && is_return_to_valid?(params["return_to"])
      previous = params["return_to"]
    elsif !external_or_blank_referer?
      previous = user_return_to
    end

    return_to = previous || my_home_path

    clear_stored_location
    return_to
  end

  # overriding bigbluebutton_rails function
  def bigbluebutton_user
    if current_user && current_user.is_a?(User)
      current_user
    else
      nil
    end
  end

  def bigbluebutton_role(room)
    # guest role that only exists in mconf-live, might be disabled in the gem
    guest_role = :attendee
    if defined?(BigbluebuttonRoom.guest_support) and BigbluebuttonRoom.guest_support
      guest_role = :guest
    end

    # first make sure the room has a valid owner
    if room.owner_type == "User"
      user = User.find_by_id(room.owner_id)
      return nil if user.nil? || user.disabled
    elsif room.owner_type == "Space"
      space = Space.find_by_id(room.owner_id)
      return nil if space.nil? || space.disabled
    else
      return nil
    end

    if current_user.nil?
      # anonymous users
      if room.private?
        :key
      else
        guest_role
      end
    else
      # Superusers has the right to create and be moderator in any room
      if current_user.superuser?
        :moderator
      elsif room.owner_type == "User"
        if room.owner.id == current_user.id
          # only the owner is moderator
          :moderator
        else
          if room.private
            :key # ask for a password if room is private
          else
            guest_role
          end
        end
      elsif room.owner_type == "Space"
        space = Space.find(room.owner.id)
        if space.admins.include?(current_user)
          :moderator
        elsif space.users.include?(current_user)
          # will be moderator if he's creating a new meeting or he already created it
          if !room.is_running? || room.user_created_meeting?(current_user)
            :moderator
          else
            :attendee
          end
        else
          if room.private
            :key
          else
            guest_role
          end
        end
      end
    end
  end

  # This method is called from BigbluebuttonRails.
  # Returns whether the current user can create a meeting in 'room'.
  def bigbluebutton_can_create?(room, role)
    ability = Abilities.ability_for(current_user)
    ability.can?(:create_meeting, room)
  end

  # This method is called from BigbluebuttonRails.
  # Returns a hash with options to override the options used when making the API call to
  # create a meeting in the room 'room'. The parameters returned are used directly in the
  # API, so the keys should match the attributes used in the API and not the columns saved
  # in the database (e.g. :attendeePW instead of :attendee_key)!
  def bigbluebutton_create_options(room)
    ability = Abilities.ability_for(current_user)
    # show the record button if the user has permissions to record
    { record: ability.can?(:record_meeting, room) }
  end

  # loads the web conference room for the current space into `@webconf_room` and fetches information
  # about it from the web conference server (`getMeetingInfo`)
  def webconf_room!
    @webconf_room = @space.bigbluebutton_room
    if @webconf_room
      begin
        @webconf_room.fetch_meeting_info
      rescue Exception
      end
    else
      raise(ActiveRecord::RecordNotFound)
    end

    @webconf_room
  end

  # Returns the translation for of a locale given its acronym (e.g. "en")
  def locale_i18n(acronym)
    configatron.locales.names[acronym.to_sym]
  end

  # The payload is used by lograge. We add more information to it here so that it is saved
  # in the log.
  def append_info_to_payload(payload)
    super

    payload[:session] = {
      id: session.id,
      ldap_session: !session[Mconf::LDAP::SESSION_KEY].blank?,
      shib_session: !session[Mconf::Shibboleth::SESSION_KEY].blank?
    } unless session.nil?
    payload[:current_user] = {
      id: current_user.id,
      email: current_user.email,
      username: current_user.username,
      name: current_user.full_name,
      superuser: current_user.superuser?,
      can_record: current_user.can_record?
    } unless current_user.nil?
    if payload[:controller] == "CustomBigbluebuttonRoomsController" && payload[:action] == "join"
      payload[:room] = {
        meetingid: @room.meetingid,
        name: @room.name,
        member: !current_user.nil?,
        user: {
          name: current_user.try(:full_name) || (params[:user].present? ? params[:user][:name] : nil)
        }
      } unless @room.nil?
    end
  end

  # Returns a boolean value denoting if the captcha in the form was filled in
  # correctly. The form has to have the 'captcha_tags' method called in them.
  # It also tries to set the errors in the model so you can do
  # 'if verify_captche && model.save!' in your controller
  def verify_captcha
    site = Site.current

    # only verify captcha for logged out users
    if current_user.blank? && site.captcha_enabled?

      # verify and try to add errors to the model
      model = instance_variable_get("@#{controller_name.singularize}")
      verify_recaptcha(private_key: site.recaptcha_private_key, model: model)
    end
  end

  private

  def set_time_zone
    Time.zone = Mconf::Timezone.user_time_zone(current_user)
  end

  def render_error_page number
    # If we're here because of an error in an after_fiter this will trigger a DoubleRender error.
    # To prevent it we'll just clear the response_body before continuing
    self.response_body = nil
    render :template => "/errors/error_#{number}", :status => number, :layout => "error"
  end

  def render_404(exception)
    @route ||= request.path
    unless Rails.application.config.consider_all_requests_local
      @exception = exception
      render_error_page 404
      log_stack_trace exception
    else
      raise exception
    end
  end

  def render_500(exception)
    unless Rails.application.config.consider_all_requests_local
      @exception = exception
      ExceptionNotifier.notify_exception exception
      render_error_page 500
      log_stack_trace exception
    else
      raise exception
    end
  end

  def render_403(exception)
    unless Rails.application.config.consider_all_requests_local
      @exception = exception
      render_error_page 403
    else
      raise exception
    end
  end

  def render_400(exception)
    unless Rails.application.config.consider_all_requests_local
      self.response_body = nil
      render(nothing: true, status: 400)
    else
      raise exception
    end
  end

  # Checks if it's ok to redirect the user to the path in `request`. Considers
  # the URL and the type of the request (e.g. xhr requests are not redirectable to).
  def request_is_redirectable?(request)
    # Some xhr request need to be stored
    xhr_paths = ["/manage/users", "/manage/spaces"]

    # This will filter xhr requests that are not for html pages. Requests for html pages
    # via ajax can change the url and we might want to store them.
    valid_format = (request.format == "text/html" || request.content_type == "text/html") && ( !request.xhr? || xhr_paths.include?(request.path) )

    path_is_redirectable?(request.path) && valid_format
  end

  # Checks if it's ok to redirect the user to `path`. Considers only the URL, not
  # the type of the request or anything else.
  def path_is_redirectable?(path)
    # Paths to which users should never be redirected back to.
    ignored_paths = [ "/login", "/users/login", "/users",
                      "/register", "/users/registration",
                      "/users/registration/signup", "/users/registration/cancel",
                      "/users/password", "/users/password/new",
                      "/users/confirmation/new", "/users/confirmation",
                      "/secure", "/secure/info", "/secure/associate", "/feedback/webconf",
                      "/pending", "/bigbluebutton/rooms/.*/join", "/bigbluebutton/rooms/.*/end"]
    ignored_paths.select{ |ignored| path.match("^"+ignored+"$") }.empty?
  end

  # If the `path` passed as a parameter to redirect the user to it is valid or not.
  # It's not valid for paths we can't redirect to or external links.
  def is_return_to_valid?(path)
    return true if path.blank?
    path_is_redirectable?(path) && !external_or_blank_url?(path)
  end

  # Store last url for post-login redirect to whatever the user last visited.
  # From: https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  def store_location
    if request_is_redirectable?(request) #&& !external_or_blank_url?(request.url)
      # Used by Mconf-Web. Can't use user_return_to because it is overridden
      # before actions and views are executed.
      session[:previous_user_return_to] = session[:user_return_to]

      # used by devise
      session[:user_return_to] = request.fullpath
      # session[:last_request_time] = Time.now.utc.to_i
    end
  end

  # Removes the stored location used to redirect post-login.
  def clear_stored_location
    session[:user_return_to] = nil
  end

  # Path to where the user would be redirect back to
  def user_return_to
    session[:user_return_to]
  end

  # Returns the previous path (the referer), if it exists and is a 'redirectable to'
  # path. Otherwise returns the fallback.
  def previous_path_or(fallback)
    session[:previous_user_return_to] || fallback
  end

  # Whether the user came from "nowhere" (no referer) or from an external URL.
  # Because we don't to redirect the user somewhere if he came from outside
  # or typed something in the address bar
  def external_or_blank_referer?
    external_or_blank_url?(request.referer)
  end

  def external_or_blank_url?(url)
    return true if url.blank?

    parsed = URI.parse(url.to_s)

    # no host on it means it's only a path, so it's not external
    return false if !parsed.try(:host)

    site_scheme = current_site.ssl? ? 'https' : 'http'
    parsed = URI.parse("#{site_scheme}://#{current_site.domain}")
    site = "#{parsed.try(:scheme)}://#{parsed.try(:host)}:#{parsed.try(:port)}"

    parsed = URI.parse(url.to_s)
    from_url = "#{parsed.try(:scheme)}://#{parsed.try(:host)}:#{parsed.try(:port)}"

    from_url != site
  end

  # A default handler for access denied exceptions. Will simply redirect the user
  # to the sign in page if the user is not logged in yet.
  def handle_access_denied exception
    respond_to do |format|
      format.html {
        if user_signed_in?
          render_403 exception
        else
          redirect_to login_path
        end
      }
      format.json { render json: { error: true, message: "You need to sign in or sign up before continuing." }, status: :unauthorized }
      format.js   { render json: { error: true, message: "You need to sign in or sign up before continuing." }, status: :unauthorized }
    end
  end
end
