# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Filters added to this controller apply to all controllers in the application.
# Likewse, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include Mconf::LocaleControllerModule

  # For extra methods like 'bigbluebutton_user', 'bigbluebutton_room', 'webconf_room!'
  include Mconf::BigbluebuttonRailsAdditions

  # For 'append_info_to_payload'
  include Mconf::LogrageAdditions

  # To ease the management of mass assignment, this adds
  # the method 'allow_params_for' in each controller
  extend Mconf::AllowParamsForModule

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '29d7fe875960cb1f9357db1445e2b063'

  before_filter :set_current_locale # Locale as param
  before_filter :set_time_zone
  before_filter :store_location

  helper_method :current_site
  helper_method :locale_i18n

  # Includes methods like render_404 and render_500
  include Mconf::ErrorRenderingModule

  # Handle errors - error pages
  rescue_from Exception, :with => :render_500
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404
  rescue_from ActionController::UnknownController, :with => :render_404
  rescue_from ActionController::RoutingError, :with => :render_404
  rescue_from ::AbstractController::ActionNotFound, :with => :render_404
  rescue_from CanCan::AccessDenied, with: :handle_access_denied

  rescue_from ActionController::InvalidCrossOriginRequest, with: :render_400
  rescue_from ActionController::UnknownFormat, with: :render_404

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
    return_to = stored_location_for(resource) || my_home_path
    clear_stored_location
    return_to
  end

  # Returns the translation for of a locale given its acronym (e.g. "en")
  def locale_i18n(acronym)
    configatron.locales.names[acronym.to_sym]
  end

  private

  def set_time_zone
    Time.zone = Mconf::Timezone.user_time_zone(current_user)
  end

  def path_is_redirectable? path
    # Paths to which users should never be redirected back to.
    ignored_paths = [ "/login", "/users/login", "/users",
                      "/register", "/users/registration",
                      "/users/registration/signup", "/users/registration/cancel",
                      "/users/password", "/users/password/new",
                      "/users/confirmation/new", "/users/confirmation",
                      "/secure", "/secure/info", "/secure/associate",
                      "/pending", "/bigbluebutton/rooms/.*/join", "/bigbluebutton/rooms/.*/end"]

    # Some xhr request need to be stored
    xhr_paths = ["/manage/users", "/manage/spaces"]

    # This will filter xhr requests that are not for html pages. Requests for html pages
    # via ajax can change the url and we might want to store them.
    valid_format = (request.format == "text/html" || request.content_type == "text/html") && ( !request.xhr? || xhr_paths.include?(path) )

    ignored_paths.select{ |ignored| path.match("^"+ignored+"$") }.empty? && valid_format
  end

  # Store last url for post-login redirect to whatever the user last visited.
  # From: https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  def store_location
    if path_is_redirectable?(request.path)
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
      format.json { render json: { error: true, message: I18n.t('_other.access_denied') }, status: :unauthorized }
      format.js   { render json: { error: true, message: I18n.t('_other.access_denied') }, status: :unauthorized }
    end
  end
end
