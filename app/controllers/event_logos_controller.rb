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

require 'RMagick'

class EventLogosController < ApplicationController
  include Magick
  
  TMP_PATH = File.join(RAILS_ROOT, "public", "images", "tmp")
  
  def precrop
    if params['event_logo']['media'].blank?
      redirect_to request.referer
      return
    end
    
    @event = Event.find_by_permalink(params[:event_id])
    @event_logo = @event.logo || EventLogo.new 

    f = File.open(File.join(TMP_PATH,"precropevent_logo-#{@event.id}"), "w+")
    f.write(params['event_logo']['media'].read)
    f.close
    @image = "tmp/" + File.basename(f.path)
    session[:tmp_event_logo] = {}
    session[:tmp_event_logo][:basename] = File.basename(f.path)
    session[:tmp_event_logo][:original_filename] = params['event_logo']['media'].original_filename
    session[:tmp_event_logo][:content_type] = params['event_logo']['media'].content_type

    reshape_image f.path, EventLogo::ASPECT_RATIO.to_f
    resize_if_bigger f.path, 600 
    
    @logo_crop_text = I18n.t('event.logo.crop')
    @form_for       = [@event,@event_logo]
    @form_url       = space_event_logo_path(@event.space, @event)
    
    render :template => "logos/precrop", :layout => false
  end


  # POST /event_logos
  # POST /event_logos.xml
  def create
    event = Event.find_by_permalink(params[:event_id])
    if params[:crop_size].present?
      crop_and_resize
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
      crop_and_resize
    end

    if event.logo.update_attributes(params[:event_logo])
      flash[:notice] = t('event.logo.created')
      redirect_to(space_event_path(event.space, event))
    else
      flash[:error] = t('error', :count => event.errors.size) + event.errors.to_xml
      redirect_to(space_event_path(event.space, event))
    end
  end
  
  
  
  private

  def crop_and_resize 
      
    img = Magick::Image.read(File.open(File.join(TMP_PATH,session[:tmp_event_logo][:basename]))).first

    crop_args = %w( x y width height ).map{ |k| params[:crop_size][k] }.map(&:to_i)
    crop_img = img.crop(*crop_args)
    f = ActionController::UploadedTempfile.open("cropevent_logo","tmp")
    crop_img.write("png:" + f.path)
    f.instance_variable_set "@original_filename",session[:tmp_event_logo][:original_filename]
    f.instance_variable_set "@content_type", session[:tmp_event_logo][:content_type]
    params[:event_logo] ||= {}
    params[:event_logo][:media] = f

  end

  def resize_if_bigger path, size
    
    f = File.open(path)
    img = Magick::Image.read(f).first
    if img.columns > img.rows && img.columns > size
      resized = img.resize(size.to_f/img.columns.to_f)
      f.close
      resized.write("png:" + path)
    elsif img.rows > img.columns && img.rows > size
      resized = img.resize(size.to_f/img.rows.to_f)
      f.close
      resized.write("png:" + path)
    end
    
  end


  def reshape_image path, aspect_ratio
    
    f = File.open(path)
    img = Magick::Image.read(f).first
    aspect_ratio_orig = (img.columns / 1.0) / (img.rows / 1.0) 
    if aspect_ratio_orig < aspect_ratio
      # target image is more 'horizontal' than original image
      target_size_y = img.rows
      target_size_x = target_size_y * aspect_ratio
    else
      # target image is more 'vertical' than original image
      target_size_x = img.columns
      target_size_y = target_size_x / aspect_ratio
    end
    # We center the image inside the white canvas
    decenter_x = -(target_size_x - img.columns) / 2;
    decenter_y = -(target_size_y - img.rows) / 2;
    
    reshaped = img.extent(target_size_x, target_size_y, decenter_x, decenter_y)
    f.close
    reshaped.write("png:" + path)
    
  end

end
