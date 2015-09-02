# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ProfilesController < ApplicationController
  before_filter :authenticate_user!

  load_and_authorize_resource :user, :find_by => :username
  load_and_authorize_resource :through => :user, :singleton => true

  def show
    respond_to do |format|
      format.html { redirect_to user_path(@user)}
      format.vcf { send_data @profile.to_vcard.to_s, :filename => "#{@user.name}.vcf" }
    end
  end

  def edit
  end

  def update_logo
    @profile.logo_image = params[:uploaded_file]

    if @profile.save
      url = logo_images_crop_path(:model_type => 'user', :model_id => @profile.user)
      respond_to do |format|
        format.json {
          render json: {
            success: true, redirect_url: url, small_image: @profile.small_logo_image?,
            new_url: @profile.logo_image.url
          }
        }
      end
    else
      format.json { render json: { success: false } }
    end
  end

  def update
    respond_to do |format|
      if @profile.update_attributes(profile_params)
        flash[:notice] = t('profile.updated')
        format.html { redirect_to edit_user_profile_path(@user) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  private

  allow_params_for :profile
  def allowed_params
    allowed = [ :organization, :phone, :mobile, :fax, :address, :city, :zipcode,
                :province, :country, :prefix_key, :description, :url, :skype, :im,
                :visibility, :logo_image, :vcard,
                :crop_x, :crop_y, :crop_w, :crop_h, :crop_img_w, :crop_img_h ]
    allowed += [:full_name] if can?(:update_full_name, @user.profile)
    allowed
  end

end
