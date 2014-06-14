# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Filters added to this controller apply to all controllers in the application.
# Likewse, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  include SimpleCaptcha::ControllerHelpers
  include Mconf::LocaleControllerModule

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '29d7fe875960cb1f9357db1445e2b063'

  # Locale as param
  before_filter :set_current_locale

  before_filter :set_time_zone

  helper_method :current_site

  # Handle errors - error pages
  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_500
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    rescue_from ActionController::RoutingError, :with => :render_404
    rescue_from ActionController::UnknownController, :with => :render_404
    rescue_from ::AbstractController::ActionNotFound, :with => :render_404
    rescue_from CanCan::AccessDenied, :with => :render_403
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
    if [login_url, new_user_session_url].include?(request.referer)
      super
    else
      stored_location_for(resource) || request.referer || my_home_path
    end
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
        :password
      else
        guest_role
      end
    else
      if room.owner_type == "User"
        if room.owner.id == current_user.id
          # only the owner is moderator
          :moderator
        else
          if room.private
            :password # ask for a password if room is private
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
            :password
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
  # Returns a hash with options to override the options saved in the database when creating
  # a meeting in the room 'room'.
  def bigbluebutton_create_options(room)
    ability = Abilities.ability_for(current_user)

    can_record = ability.can?(:record_meeting, room)
    if Site.current.webconf_auto_record
      # show the record button if the user has permissions to record
      { :record => can_record }
    else
      # only enable recording if the room is set to record and if the user has permissions to
      # used to forcibly disable recording if a user has no permission but the room is set to record
      record = room.record && can_record
      { :record => record }
    end
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

  private

  def set_time_zone
    Time.zone = Mconf::Timezone.user_time_zone(current_user)
  end

  def render_404(exception)
    # FIXME: this is never triggered, see the bottom of routes.rb
    @exception = exception
    render :template => "/errors/error_404", :status => 404, :layout => "error"
  end

  def render_500(exception)
    @exception = exception
    pp exception
    render :template => "/errors/error_500", :status => 500, :layout => "error"
  end

  def render_403(exception)
    @exception = exception
    render :template => "/errors/error_403", :status => 403, :layout => "error"
  end

end
