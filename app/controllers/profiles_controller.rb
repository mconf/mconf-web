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

class ProfilesController < ApplicationController
  before_filter :user!

  authorization_filter :manage, :profile, :except => [ :show ]

  before_filter :unique_profile, :only => [:new, :create]

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
      if @profile.authorize? :read, :to => current_user
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

