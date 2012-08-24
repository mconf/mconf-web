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

require "digest/sha1"
class UsersController < ApplicationController
  include ActionController::StationResources
  include ActionController::Agents

  before_filter :space!, :only => [:index]
  before_filter :webconf_room!, :only => [:index]

  load_and_authorize_resource

  # GET /users
  # GET /users.xml
  def index
    @users = space.users.sort {|x,y| x.name <=> y.name }
    #@groups = @space.groups.all(:order => "name ASC")
    #@users_without_group = @users.select{|u| u.groups.select{|g| g.space==@space}.empty?}
    #if params[:edit_group]
    #  @editing_group = @space.groups.find(params[:edit_group])
    #else
    #  @editing_group = Group.new()
    #end

    respond_to do |format|
      format.html { render :layout => 'spaces_show' }
      format.xml { render :xml => @users }
    end

  end

  # GET /users/1
  # GET /users/1.xml
  def show
    user

    if @user.spaces.size > 0
      @recent_activity = ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>15, :order=>'updated_at DESC', :conditions => {:author_id => @user.id, :author_type => "User"} },{:containers => @user.spaces, :contents => [:posts, :events, :attachments]})
    else
      @recent_activity = ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>15, :order=>'updated_at DESC' },{:containers => @user.spaces, :contents => [:posts, :events, :attachments]})
    end

    @profile = user.profile!

    respond_to do |format|
      format.html { render 'profiles/show' }
      format.xml { render :xml => user }
    end
  end

  def edit
    if current_user == @user # User editing himself
      @shib_user = session.has_key?(:shib_data)
      @shib_provider = session[:shib_data]["Shib-Identity-Provider"] if @shib_user
    end
    render :layout => 'no_sidebar'
  end

  def update
    params[:user].delete(:username)
    params[:user].delete(:email)
    password_changed = params[:user].has_key?(:password) && !params[:user][:password].empty?
    updated = if password_changed
                @user.update_with_password(params[:user])
              else
                params[:user].delete(:current_password)
                @user.update_without_password(params[:user])
              end

    if updated
      # User editing himself
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true if current_user == @user

      flash = { :success => t("user.updated") }
      redirect_to edit_user_path(@user), :flash => flash
    else
      render "edit", :layout => 'no_sidebar'
    end

  end

  def edit_bbb_room
    @room = current_user.bigbluebutton_room
    @server = @room.server
    @redir_to = home_path

    respond_to do |format|
      format.html{
        if request.xhr?
          render :layout => false
        end
      }
    end
  end


  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    user.disable

    flash[:notice] = t('user.disabled', :username => @user.username)

    respond_to do |format|
      format.html {
        if !@space && current_user.superuser?
          redirect_to manage_users_path
        elsif !@space
          redirect_to root_path
        else
          redirect_to(space_users_path(@space))
        end
      }
      format.xml  { head :ok }
    end
  end

  def enable
    @user = User.find_with_disabled(params[:id])

    unless @user.disabled?
      flash[:notice] = t('user.error.enabled', :name => @user.username)
      redirect_to request.referer
      return
    end

    @user.enable

    flash[:success] = t('user.enabled')
    respond_to do |format|
      format.html {
          redirect_to manage_users_path
      }
      format.xml  { head :ok }
    end
  end

  # GET /users/select_users.json
  # This method returns a list with the login and name of all users
  def select_users
    tags = User.select_all_users(params[:q])

    respond_to do |format|
      format.json { render :json => tags }
    end
  end

  # Returns info of the current_user
  def current
    @user = current_user
    @user = nil if @user == Anonymous.current
    respond_to do |format|
      format.xml
      format.json
    end
  end

end
