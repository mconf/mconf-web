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

class AvatarsController < ApplicationController

  def precrop
    if params['avatar'].blank? || params['avatar']['media'].blank?
      render "logos/precrop_no_image", :layout => false
      return
    end

    @user = User.find_by_login(params[:user_id])
    @avatar = @user.profile!.logo || Avatar.new

    temp_logo = TempLogo.new(Avatar, @user, params[:avatar])
    TempLogo.to_session(session, temp_logo)
    size = temp_logo.size
    size = "#{size[0]}x#{size[1]}"

    render :template => "logos/precrop",
           :layout => false,
           :locals => {:logo_crop_text => t('avatar.crop'),
                       :p_form_for => @avatar,
                       :p_form_url => [@user, :avatar],
                       :image => temp_logo.image,
                       :image_size => size
                      }
  end

  def create
    user = User.find_by_login(params[:user_id])
    if params[:crop_size].present?
      temp_logo = TempLogo.from_session(session)
      params[:avatar] = temp_logo.crop_and_resize params[:crop_size]
    end
    @avatar = user.profile!.build_logo(params[:avatar])
    if @avatar.save
      flash[:success] = t('avatar.created')
      redirect_to user_path(user)
    else
      flash[:error] = t('error', :count => @avatar.errors.size) + @avatar.errors.to_xml
      redirect_to user_path(user)
    end

  end

  def update
    user = User.find_by_login(params[:user_id])
    if params[:crop_size].present?
      temp_logo = TempLogo.from_session(session)
      params[:avatar] = temp_logo.crop_and_resize params[:crop_size]
    end
    @avatar = user.profile
    if @avatar.logo.update_attributes(params[:avatar])
      flash[:success] = t('avatar.created')
      redirect_to user_path(user)
    else
      flash[:error] = t('error', :count => @avatar.logo.errors.size) + @avatar.logo.errors.to_xml
      redirect_to user_path(user)
    end
  end

  def show
    user = User.find_by_login(params[:user_id])

    if user.logo.present?
      logo = user.logo
    else
      raise ActiveRecord::RecordNotFound
    end

    params[:size] ||= "64"
    logo =  (logo.thumbnails.map(&:thumbnail).include?(params[:size]) ? logo.thumbnails.find_by_thumbnail(params[:size]) : logo.thumbnails.find_by_thumbnail("64"))
    send_data logo.__send__(:current_data),
                    :filename => logo.filename,
                    :type => logo.content_type,
                    :disposition => logo.class.resource_options[:disposition].to_s
  end

end
