# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ProfilesController < ApplicationController
  before_filter :unique_profile, :only => [:new, :create]

  load_and_authorize_resource :user, :find_by => :username
  load_and_authorize_resource :through => :user, :singleton => true

  # if params[:hcard] then hcard is rendered
  def show
    respond_to do |format|
      format.html { redirect_to user_path(@user)}
      format.xml { render :xml => @profile }
      format.vcf { send_data @profile.to_vcard.to_s, :filename => "#{ @user.name}.vcf" }
    end
  end

  def edit
    if params[:hcard_uri]
      @profile.from_hcard(params[:hcard_uri])
    end
  end

  def update_logo
    @profile.logo_image = params[:uploaded_file]

    if @profile.save
      respond_to do |format|
        url = logo_images_crop_path(:model_type => 'user', :model_id => @profile.user)
        format.json { render :json => { :success => true, :redirect_url => url } }
      end
    else
      format.json { render :json => { :success => false } }
    end
  end

  def update
    respond_to do |format|
      if @profile.update_attributes(profile_params)
        flash[:notice] = t('profile.updated')
        format.html { redirect_to user_path(@user) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  def destroy
    @profile.destroy
    flash[:notice] = t('profile.deleted')
    respond_to do |format|
      format.html { redirect_to(user_path(@user)) }
      format.xml  { head :ok }
    end
  end

  private

  def user!
    @user = User.find_with_param(params[:user_id]) || raise(ActiveRecord::RecordNotFound)
    @profile = @user.profile!
  end

  #this is used to create the hcard microformat of an user in order to show it in the application
  def hcard
    if @profile.nil?
      flash[:notice]= t('profile.must_create')
      redirect_to new_user_profile_path(current_user)
    else
      render :partial=>'public_hcard'
      if can?(:read, @profile)
        render :partial=>'private_hcard'
      end
    end
  end

  def unique_profile
    unless @user.profile.new_record?
      flash[:error] = t('profile.error.exist')
      redirect_to user_path(@user)
    end
  end

  allow_params_for :profile
  def allowed_params
    [ :organization, :phone, :mobile, :fax, :address, :city, :zipcode,
      :province, :country, :prefix_key, :description, :url, :skype, :im,
      :visibility, :full_name, :logo_image ]
  end

end
