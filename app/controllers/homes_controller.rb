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

  def index
  end
  
  def show

    #TODO temporary implementation of a bbb room for this home
    @bbb_infos = BBB_API.get_meetings
    @bbb_rooms = Array.new
    @roomOpen = false

    if @bbb_infos[:messageKey] != "noMeetings"
      node = @bbb_infos[:meetings][:meeting]
      if node.kind_of?(Array)
        node.each do |v|
          if v[:hasBeenForciblyEnded] != "true"
            @bbb_rooms.push(BBB_API.get_meeting_info(v[:meetingID], v[:moderatorPW]))
            @roomOpen = true
          end
        end
      else
        if node[:hasBeenForciblyEnded] != "true"
          @bbb_rooms.push(BBB_API.get_meeting_info(node[:meetingID], node[:moderatorPW]))
          @roomOpen = true
        end
      end
    end

    unless current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date ASC")
    end
    @contents_per_page = params[:per_page] || 15
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents 
    @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )

    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)
  end

  def new_room
    respond_to do |format|
      format.html{
        if request.xhr?
          render :layout => false
        end
      }
    end
  end

  def end_room
    BBB_API.end_meeting(params[:id], params[:pw])
    respond_to do |format|
      format.html { redirect_to :action => "show" }
    end
  end


  def create_room
    BBB_API.create_meeting(params[:home][:title], params[:home][:title], "mp", "ap", "Welcome to Mconf!")
    respond_to do |format|
      format.html { redirect_to :action => "show" }
    end
  end

  def join_room
    url = BBB_API.moderator_url(params[:id], current_user.name, params[:pw])
    respond_to do |format|
      format.html { redirect_to url }
    end
  end

end
