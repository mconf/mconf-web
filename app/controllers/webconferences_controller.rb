# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# TODO: move :show to SpacesController#webconference

# This controller contain some helper methods that add up to the methods
# in CustomBigbluebuttonRoomsController. These methods are specific for dealing
# with webconference rooms in Mconf-Web (that belong specifically to spaces and
# users), so they were added here to be isolated.
class WebconferencesController < ApplicationController
  before_filter :space!, :except => [:user_edit]
  before_filter :webconf_room!, :except => [:user_edit]

  before_filter :find_room
  before_filter :authorize_room!

  layout 'spaces_show', :only => [:space_show]
  layout 'application', :only => [:user_edit]

  def space_show
    # FIXME Temporarily matching users by name, should use the userID
    @webconf_attendees = []
    unless @webconf_room.attendees.nil?
      @webconf_room.attendees.each do |attendee|
        profile = Profile.find(:all, :conditions => { "full_name" => attendee.full_name }).first
        unless profile.nil?
          @webconf_attendees << profile.user
        end
      end
    end

  end

  # Called by users to edit a webconference room. It's different from the
  # standard CustomBigbluebuttonRoomsController#edit, that allows an admin to
  # edit *everything* in a room. This one is a lot more restricted.
  def user_edit
    @redirect_to = home_path
    respond_to do |format|
      format.html {
        if request.xhr?
          render :layout => false
        end
      }
    end
  end

  private

  def find_room
    if params[:user_id]
      @room = User.find_by_username(params[:user_id]).bigbluebutton_room
    else
      @room = Space.find_by_permalink(params[:space_id]).bigbluebutton_room
    end
  end

  # basically the same as calling `authorize!` in every action, but in a
  # before_filter.
  def authorize_room!
    authorize! action_name.to_sym, @room
  end

end
