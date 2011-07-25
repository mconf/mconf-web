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

class FrontpageController < ApplicationController


  def index
#    @users = space.users
#
#    #recent_spaces = The last spaces created
#    @recent_spaces = Space.find(:all, :conditions => {:public => true},:order => "created_at Desc").first(3)
#
#    #relevant_users = The relevant users are the users which have more posts
#    @relevant_users = User.find(:all).sort_by{|user| user.posts.size}.reverse.first(4)
#
#    #recent_posts = The latest updated threads in public spaces
#    @recent_posts = Post.find(:all, :conditions => {:parent_id => nil}, :order => "created_at Desc").select{|p| !p.space.disabled? && p.space.public == true}.first(2)
#
#    #recent_events = The upcoming events in public spaces
#    @recent_events = Event.find(:all, :order => "start_date Desc").select{|p| !p.space.disabled? && p.space.public? &&  p.start_date && p.start_date.future?}.first(2)

    # Fetch the meetings running in the server and order by participant_count
    # TODO Temporarily using the first server
    @server = BigbluebuttonServer.first
    begin
      @server.fetch_meetings

      # statistics
      @stats = {}
      @stats[:meetings] = @server.meetings.select { |m| m.is_running? }.count
      @stats[:users] = User.count
      @stats[:spaces] = Space.count

      # spaces with webconferences running
      spaces_ids = @server.meetings.select{ |m| m.owner_type == "Space" }.map{ |m| m.owner_id }
      @running_spaces = Space.find_all_by_id(spaces_ids).select{ |s| s.public? }
      @running_spaces.each do |space|
        space.bigbluebutton_room.fetch_meeting_info
      end
      @running_spaces.sort! { |x,y| y.bigbluebutton_room.participant_count <=> x.bigbluebutton_room.participant_count }
    rescue Exception
    end

    # Get the spaces with more users and fetch info about their webconference rooms
    @popular_spaces = Space.public.sort_by{|s| s.users.size}.reverse.first(3)
    @popular_spaces.each do |space|
      begin
        space.bigbluebutton_room.fetch_meeting_info
      rescue Exception
      end
    end

    respond_to do |format|
      if logged_in?
        format.html { redirect_to home_path}
      else
        format.html # index.html.erb
        format.xml  { render :xml => @spaces }
        format.atom
      end
    end
  end


  def about
    @global = Space.find_by_name("GLOBAL")
    @latest_global_posts = Post.last_news(@global)
    render :layout=>false
  end

  def about2
    render :layout=>false
  end

  def performance
    render :layout=>false
  end
end
