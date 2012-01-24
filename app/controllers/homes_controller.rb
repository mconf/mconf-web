# -*- coding: utf-8 -*-
# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

class HomesController < ApplicationController

  before_filter :authentication_required
  respond_to :json, :only => [:user_rooms]
  respond_to :html, :except => [:user_rooms]

  def index
  end

  def show
    @bbb_rooms = BigbluebuttonRoom.where("owner_id = ? AND owner_type = ?", current_user.id, current_user.class.name)
    @bbb_rooms.each do |room|
      begin
       room.fetch_meeting_info
      rescue Exception
      end
    end

    # TODO: probably unnecessary
    if params[:update_rooms]
      render :partial => 'homes/rooms'
      return
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

    @contents_per_page = params[:per_page] || 5
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents
    @all_contents = ActiveRecord::Content.paginate({ :page => params[:page], :per_page => @contents_per_page.to_i, :order => 'updated_at DESC' },
                                                   { :containers => current_user.spaces, :contents => @contents} )

    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)
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
