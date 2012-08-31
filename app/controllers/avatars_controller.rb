# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class AvatarsController < ApplicationController

  def precrop
    if params['avatar'].blank? || params['avatar']['media'].blank?
      render "logos/precrop_no_image", :layout => false
      return
    end

    @user = User.find_by_username(params[:user_id])
    @avatar = @user.profile!.logo || Avatar.new

    temp_logo = TempLogo.new(Avatar, @user, params[:avatar])
    TempLogo.to_session(session, temp_logo)
    size = temp_logo.size
    size = "#{size[1]}x#{size[0]}"

    render :template => "logos/precrop",
           :layout => false,
           :locals => { :form_for_element => @avatar,
                        :form_url => [@user, :avatar],
                        :image => temp_logo.image,
                        :image_size => size,
                        :aspect_ratio => Avatar::ASPECT_RATIO_S }
  end

  def create
    user = User.find_by_username(params[:user_id])
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
    user = User.find_by_username(params[:user_id])
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
    user = User.find_by_username(params[:user_id])

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
