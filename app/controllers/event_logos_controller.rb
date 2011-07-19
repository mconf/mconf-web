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

class EventLogosController < ApplicationController
  
  def precrop
    if params['logo']['media'].blank?
      redirect_to request.referer
      return
    end
    
    @event = Event.find_by_permalink(params[:event_id])
    @event_logo = @event.logo || EventLogo.new 

    temp_logo = TempLogo.new(EventLogo, @event, params[:logo])
    TempLogo.to_session(session, temp_logo)
    size = temp_logo.size
    size = "#{size[0]}x#{size[1]}"
                      
    render :template => "logos/precrop",
           :layout => false,
           :locals => {:logo_crop_text => t('event.logo.crop'),
                       :p_form_for => [@event,@event_logo],
                       :p_form_url => space_event_logo_path(@event.space, @event),
                       :image => temp_logo.image,
                       :image_size => size
                      }
  end


  # POST /event_logos
  # POST /event_logos.xml
  def create
    event = Event.find_by_permalink(params[:event_id])
    if params[:crop_size].present?
      temp_logo = TempLogo.from_session(session)
      params[:event_logo] = temp_logo.crop_and_resize params[:crop_size]
    end
    
    @event_logo = event.build_logo(params[:event_logo])
    

    if @event_logo.save
      flash[:notice] = t('event.logo.created')
      redirect_to(space_event_path(event.space, event))
    else
      flash[:error] = t('error', :count => @event_logo.errors.size) + @event_logo.errors.to_xml
      redirect_to(space_event_path(event.space, event))
    end
  end

  # PUT /event_logos/1
  # PUT /event_logos/1.xml
  def update
    event = Event.find_by_permalink(params[:event_id])
    if params[:crop_size].present?
      temp_logo = TempLogo.from_session(session)
      params[:event_logo] = temp_logo.crop_and_resize params[:crop_size]
    end

    if event.logo.update_attributes(params[:event_logo])
      flash[:notice] = t('event.logo.created')
      redirect_to request.referer
    else
      flash[:error] = t('error', :count => event.errors.size) + event.errors.to_xml
      redirect_to request.referer
    end
  end
  


end
