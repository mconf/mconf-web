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

  # To configure and customize BigbluebuttonRails
  include Mconf::BigbluebuttonRailsControllerModule

  # To configure lograge
  include Mconf::LogrageControllerModule

  # Controls the automatic redirects (e.g. after a sign in)
  include Mconf::RedirectControllerModule

  # Guest users
  include Mconf::GuestUserModule

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery with: :exception

  before_filter :set_current_locale # Locale as param
  before_filter :set_time_zone
  before_filter :store_location

  helper_method :current_site
  helper_method :locale_i18n
  helper_method :parse_boolean

  # Methods to render error pages and deal with exceptions
  include Mconf::ErrorsControllerModule

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

  # Returns the translation for of a locale given its acronym (e.g. "en")
  def locale_i18n(acronym)
    Rails.application.config.locale_names[acronym.to_sym]
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

  # Code that to DRY out permitted param filtering
  # The controller declares allow_params_for :model_name and defines allowed_params
  def self.allow_params_for(instance_name)
    instance_name ||= controller_name.singularize.to_sym

    define_method("#{instance_name}_params") do
      unless params[instance_name].blank?
        params[instance_name].permit(*allowed_params)
      else
        {}
      end
    end
  end

  # Redirects to the URL specified in the parameters.
  # If the parameter is not set, behaves exactly like `redirect_to`.
  def redirect_to_p(options={}, response_status={})
    unless params[:redir_url].blank?
      redirect_to params[:redir_url], response_status
    else
      redirect_to options, response_status
    end
  end

  # Redirects to the URL specified in the parameters.
  # If the parameter is not set, behaves exactly like `render`.
  def render_p(action=nil, response_status={})
    unless params[:redir_url].blank?
      redirect_to params[:redir_url], response_status
    else
      render action, response_status
    end
  end

  # Returns 404 for all routes if the events are disabled
  def require_events_mod
    unless Mconf::Modules.mod_enabled?('events')
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  # Returns 404 for all routes if the spaces are disabled
  def require_spaces_mod
    unless Mconf::Modules.mod_enabled?('spaces')
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  # Returns 404 for all routes if the activities are disabled
  def require_activities_mod
    unless Mconf::Modules.mod_enabled?('activities')
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def parse_boolean(value)
    ActiveRecord::ConnectionAdapters::Column.value_to_boolean(value)
  end

  # To be used in `before_filter`s in actions that render modal windows.
  # Will redirect the user if not using xhr (not showing as a proper modal).
  def force_modal
    if !request.xhr?
      if request.referer.blank?
        if user_signed_in?
          redirect_to my_home_path(automodal: request.path)
        else
          redirect_to root_path(automodal: request.path)
        end
      else
        # redirects back to the referer but including a new parameter in the URL
        # to automatically open it as a modal window
        referer = request.referer
        uri = URI.parse(referer)

        params = uri.query.blank? ? {} : CGI::parse(uri.query)
        params['automodal'] = request.path
        params = URI.encode_www_form(params)

        site = "#{uri.scheme}://#{uri.host}"
        site = "#{site}:#{uri.port}" if ![80, 443].include?(uri.port)
        site = "#{site}#{uri.try(:path)}?#{params}"

        redirect_to site
      end
    end
  end

  private

  def set_time_zone
    Time.zone = Mconf::Timezone.user_time_zone(current_user)
  end

end
