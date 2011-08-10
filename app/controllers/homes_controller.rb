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

require 'bigbluebutton-api'

class HomesController < ApplicationController

  before_filter :authentication_required
  respond_to :json, :only => [:user_rooms]
  respond_to :html, :except => [:user_rooms]

  def index
  end

  def show
    @server = BigbluebuttonServer.first
    @bbb_rooms = BigbluebuttonRoom.where("owner_id = ? AND owner_type = ?", current_user.id, current_user.class.name)
    @bbb_rooms.each do |room|
      begin
       room.fetch_meeting_info
      rescue Exception
      end
    end

    if params[:update_rooms]
      render :partial => 'homes/rooms'
      return
    end

    unless current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date ASC")
    end
    @contents_per_page = params[:per_page] || 5
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents
    @all_contents = ActiveRecord::Content.paginate({ :page => params[:page], :per_page => @contents_per_page.to_i, :order => 'updated_at DESC' },
                                                   { :containers => current_user.spaces, :contents => @contents} )

    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)
  end

  def new_room
    @server = BigbluebuttonServer.first
    @room = BigbluebuttonRoom.new(:owner => current_user, :server => BigbluebuttonServer.first, :logout_url => home_url)
    respond_to do |format|
      format.html{
        if request.xhr?
          render :layout => false
        end
      }
    end
  end

  def user_rooms
    # TODO: filter only the attributes we need to return
    array = current_user.accessible_rooms
    render :json => array
  end

end
