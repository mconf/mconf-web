# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ProfilesController < ApplicationController
  before_filter :unique_profile, :only => [:new, :create]

  load_and_authorize_resource :user
  load_and_authorize_resource :through => :user, :singleton => true

  # GET /profile
  # GET /profile.xml
  # if params[:hcard] then hcard is rendered
  def show
    respond_to do |format|
      format.html { redirect_to user_path(@user)}
      format.xml { render :xml => @profile }
      format.vcf { send_data @profile.to_vcard.to_s, :filename => "#{ @user.name}.vcf" }
    end
  end

  # GET /profiles/edit
  def edit
    if params[:hcard_uri]
      @profile.from_hcard(params[:hcard_uri])
    end
  end

  # PUT /profile
  # PUT /profile.xml
  def update
    respond_to do |format|
      if @profile.update_attributes(params[:profile])
        flash[:notice] = t('profile.updated')
        format.html { redirect_to user_path(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @profile.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /profile
  # DELETE /profile.xml
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
      redirect_to new_space_user_profile_path(@space, :user_id=>current_user.id)
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
end
