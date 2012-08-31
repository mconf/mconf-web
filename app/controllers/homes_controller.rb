# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class HomesController < ApplicationController

  before_filter :authenticate_user!
  respond_to :json, :only => [:user_rooms]
  respond_to :html, :except => [:user_rooms]

  def index
  end

  def show
    @room = current_user.bigbluebutton_room
    begin
      @room.fetch_meeting_info
    rescue BigBlueButton::BigBlueButtonException
    end

    unless current_user.spaces.empty?
      @today_events = Event.
        within(DateTime.now.beginning_of_day, DateTime.now.end_of_day).
        in(current_user.spaces).
        order("start_date ASC").all
      @upcoming_events = Event.in(current_user.spaces).
        where('end_date >= ?', DateTime.now.end_of_day).
        limit(5).order("start_date ASC").all
    end

    @update_act = params[:contents] ? true : false

    @contents_per_page = params[:per_page] || 15
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents
    @all_contents = ActiveRecord::Content.paginate({ :page => params[:page], :per_page => @contents_per_page.to_i, :order => 'updated_at DESC' },
                                                   { :containers => current_user.spaces, :contents => @contents} )
    @private_messages = current_user.unread_private_messages
  end

  # renders a json with the webconference rooms accessible to the current user
  # response example:
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
  def user_rooms
    array = current_user.accessible_rooms || []
    mapped_array = array.map{ |r|
      link = join_bigbluebutton_room_path(r, :mobile => '1')
      { :bigbluebutton_room => { :name => r.name, :join_path => link, :owner => owner_hash(r.owner) } }
    }
    render :json => mapped_array
  end

  private

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
