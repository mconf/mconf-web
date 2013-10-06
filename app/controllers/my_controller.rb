# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# This controller includes actions that are specific for the current user and shouldn't be
# accessed by anybody else (e.g. home, recordings, activity, etc).
class MyController < ApplicationController

  before_filter :authenticate_user!
  respond_to :json, :only => [:rooms]
  respond_to :html, :except => [:rooms]

  before_filter :prepare_user_room, :only => [:home, :activity, :room_recordings]

  layout :determine_layout

  def determine_layout
    case params[:action].to_sym
    when :activity
      "no_sidebar"
    when :room_edit
      if request.xhr?
        false
      else
        "application"
      end
    when :room_recordings
      if params[:partial]
        false
      else
        "no_sidebar"
      end
    when :edit_recording
      if request.xhr?
        false
      else
        "application"
      end
    else
      "application"
    end
  end

  def home
    @user_spaces = current_user.spaces
    unless @user_spaces.empty?
      @today_events = Event.
        within(DateTime.now.beginning_of_day, DateTime.now.end_of_day).
        where(:space_id => @user_spaces).
        order("start_date ASC").all
      @upcoming_events = Event.where(:space_id => @user_spaces).
        where('end_date >= ?', DateTime.now.end_of_day).
        limit(5).order("start_date ASC").all
    end

    @contents_per_page = 5
    @all_contents = RecentActivity.where(:owner_id => current_user.spaces, :owner_type => 'Space')
      .limit(@contents_per_page)
      .order('updated_at DESC')

    @private_messages = current_user.unread_private_messages
  end

  def activity
    @contents_per_page = params[:per_page] || 20
    @all_contents = RecentActivity.where(:owner_id => current_user.spaces, :owner_type => 'Space')
      .paginate(:page => params[:page], :per_page => @contents_per_page.to_i, :order => 'updated_at DESC')
  end

  # Renders a json with the webconference rooms accessible to the current user
  # Response example:
  #
  # [
  #   { "bigbluebutton_room":
  #     { "name":"Admins Room", "join_path":"/bigbluebutton/servers/default-server/rooms/admins-room/join?mobile=1",
  #       "owner":{ "type":"User", "id":"1" } }
  #   }
  # ]
  #
  # The attribute "owner" will follow one of the examples below:
  # "owner":null
  # "owner":{ "type":"User", "id":1 }
  # "owner":{ "type":"Space", "id":1, "name":"Space's name", "public":true }
  #
  # Note: this route exists so the mobile client can get the rooms available for the user
  def rooms
    array = current_user.accessible_rooms || []
    mapped_array = array.map{ |r|
      link = join_bigbluebutton_room_path(r, :mobile => '1')
      { :bigbluebutton_room => { :name => r.name, :join_path => link, :owner => owner_hash(r.owner) } }
    }
    render :json => mapped_array
  end

  # Called by users to edit a webconference room. It's different from the
  # standard CustomBigbluebuttonRoomsController#edit, that allows an admin to
  # edit *everything* in a room. This one is a lot more restricted.
  def room_edit
    @room = current_user.bigbluebutton_room
    @redir_url = home_path
  end

  # List of recordings for the current user's web conference room.
  def room_recordings
    @room = current_user.bigbluebutton_room
    @recordings = @room.recordings.published().order("end_time DESC")
    if params[:limit]
      @recordings = @recordings.first(params[:limit].to_i)
    end
  end

  # Page to edit a recording.
  def edit_recording
    @redir_url = room_recordings_path # TODO: not working, no support on bbb_rails
    @recording = BigbluebuttonRecording.find_by_recordid(params[:id])
    authorize! :user_edit, @recording
  end

  private

  def prepare_user_room
    @room = current_user.bigbluebutton_room
    begin
      @room.fetch_meeting_info
    rescue BigBlueButton::BigBlueButtonException
    end
  end

  def owner_hash(owner)
    if owner.nil?
      nil
    else
      hash = { :type => owner.class.name, :id => owner.id }

      if owner.instance_of?(Space)
        space_hash = { :name => owner.name, :public => owner.public?, :member => owner.actors.include?(current_user) }
        hash.merge!(space_hash)
      end

      hash
    end
  end

end
