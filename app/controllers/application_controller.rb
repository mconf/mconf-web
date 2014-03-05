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

  # TODO: review, we shouldn't need this with cancan loading the resources
  helper_method :space, :space!

  # Handle errors - error pages
  unless Rails.application.config.consider_all_requests_local
    rescue_from Exception, :with => :render_500
    rescue_from ActiveRecord::RecordNotFound, :with => :render_404
    rescue_from ActionController::RoutingError, :with => :render_404
    rescue_from ActionController::UnknownController, :with => :render_404
    rescue_from ::AbstractController::ActionNotFound, :with => :render_404
    rescue_from CanCan::AccessDenied, :with => :render_403
  end

  # TODO: do we really need this now that cancan loads the resources?
  def space
    @space ||= Space.find_with_param(params[:space_id])
  end

  # This method is the same as space, but raises error if no Space is found
  # TODO: do we really need this now that cancan loads the resources?
  def space!
    space || raise(ActiveRecord::RecordNotFound)
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
    stored_location_for(resource) || my_home_path
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
    # TODO: temporary guest role that only exists in mconf-live
    guest_role = :attendee
    if defined?(BigbluebuttonRoom.guest_support) and
        BigbluebuttonRoom.guest_support
      guest_role = :guest
    end

    # when a user or a space is disabled the owner of the room is nil (because when trying to find
    # the user/room only the ones that are *not* disabled are returned) so we check if the owner is
    # not present we assume the room cannot be accessed
    # TODO: not the best solution, we should actually find a way to check if owner.disabled is true
    return nil unless room.owner

    unless bigbluebutton_user.nil?

      # user rooms
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

      # space rooms
      elsif room.owner_type == "Space"
        space = Space.find(room.owner.id)
        if space.users.include?(current_user)
          # space members are moderators
          :moderator
        else
          if room.private
            :password
          else
            guest_role
          end
        end
      end

    # anonymous users
    else
      if room.private?
        :password
      else
        guest_role
      end
    end
  end

  # This method is called from BigbluebuttonRails
  def bigbluebutton_can_create?(room, role)
    ability = Abilities.ability_for(current_user)
    can_create = ability.can?(:create_meeting, room)

    # if the user can create the meeting we have to check whether the record flag will be
    # set or not
    # TODO: this would be better if it was possible to send this flag in the create call to
    #   BigbluebuttonRails, not by changing the attribute in the db.
    if can_create
      can_record = ability.can?(:record_meeting, room)

      # with this option set, we always set record the flag according to the user's permissions
      if Site.current.webconf_auto_record
        room.update_attribute(:record, can_record)

      # in this case the user has to set or unset the recording flag himself, so we just make
      # sure that if he can't record the flag is unset, otherwise leave it as it is
      else
        room.update_attribute(:record, false) unless can_record
      end

    end

    can_create
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
