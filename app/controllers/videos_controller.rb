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

class VideosController < ApplicationController
  before_filter :space!
  
#  if params[:show_video]
#    if @space.event.agenda.present?
#      @video_entries = @event.agenda.agenda_entries.select{|ae| ae.past? & ae.recording?}
#    else
#      @video_entries = []
#    end
#    
#    #this is because googlebot asks for Arrays of videos and params[:show_video].to_i failed
#    if params[:show_video].class == String
#      @display_entry = AgendaEntry.find(params[:show_video].to_i)
#    else
#      @display_entry = nil
#    end
#  end

  def index
    
    @events = space.events
    @space_videos = []
    
    @events.each do |event|
      
        @event_videos = []
      
        if event.agenda.present?
          @event_videos = event.agenda.agenda_entries.select{|ae| ae.past? & ae.recording?}
          
          @event_videos.each do |video|
            @space_videos << video
          end
          
        end
    end
 
    
    if params[:show_video].class == String
      @display_entry = AgendaEntry.find(params[:show_video].to_i)
    else
      if @space_videos[0]
        @display_entry = @space_videos[0];
      else
        @display_entry = nil
      end 
    end

    
    respond_to do |format|
      format.html
    end
  end
   
end
