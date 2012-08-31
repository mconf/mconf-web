# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Filters added to this controller apply to all controllers in the application.
# Likewse, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Be sure to include AuthenticationSystem in Application Controller instead
  include SimpleCaptcha::ControllerHelpers
  include LocaleControllerModule

  # alias_method :rescue_action_locally, :rescue_action_in_public

  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '29d7fe875960cb1f9357db1445e2b063'

  # Don't log passwords
  config.filter_parameter :password, :password_confirmation

  # Handle errors - error pages
  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_500
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    rescue_from ActionController::RoutingError, :with => :render_404
    rescue_from ActionController::UnknownController, :with => :render_404
    rescue_from ::AbstractController::ActionNotFound, :with => :render_404
    rescue_from CanCan::AccessDenied, :with => :render_403
  end

  # This method calls one from the plugin, to get the Space from params or session
  def space
    @space ||= current_container(:type => :space, :path_ancestors => true)
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
    user = nil
    unless bigbluebutton_user.nil? # user belongs to mconf
      if room.owner_type == "User" # room belongs to a user
        if room.owner.id == current_user.id
          :moderator # join as moderator if current_user is the room owner
        else
          if room.private
            :password # ask for a password if room is private
          else
            :attendee # join as attendee if current_user isn't the room owner
          end
        end
      elsif room.owner_type == "Space" # room belongs to a space
        space = Space.find(room.owner.id)
        space.users.each do |u|
          if u.id == current_user.id
            user = u
            break
          end
        end
        unless user.nil?
          :moderator # join as moderator if current_user belongs to this space
        else
          if room.private
            :password # ask for password if current_user don't belongs to this space and room is private
          else
            :attendee # join as attendee if current_user don't belongs to this space and room isn't private
          end
        end
      end
    else
      if room.private?
        :password #ask for a password
      else
        :attendee
      end
    end
  end

  # This method is the same as space, but raises error if no Space is found
  def space!
    space || raise(ActiveRecord::RecordNotFound)
  end

  helper_method :space, :space!

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

  # TODO: it's pretty annoying to show this in every page
  before_filter :not_activated_warning
  def not_activated_warning
    if user_signed_in? && !current_user.confirmed?
      flash[:notice] = t('user.not_activated', :url => new_user_confirmation_path)
    end
  end

  before_filter :set_time_zone
  def set_time_zone
    if current_user && current_user.is_a?(User) && current_user.timezone && !current_user.timezone.empty?
      Time.zone = current_user.timezone
    else
      Time.zone = 'Madrid'
    end
  end

  # Locale as param
  before_filter :set_vcc_locale

  private

  def accept_language_header_locale
    request.env['HTTP_ACCEPT_LANGUAGE'].scan(/^[a-z]{2}/).first.to_sym if request.env['HTTP_ACCEPT_LANGUAGE'].present?
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
