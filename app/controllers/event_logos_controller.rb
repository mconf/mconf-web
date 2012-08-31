# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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
