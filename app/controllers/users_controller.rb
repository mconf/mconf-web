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

  # Permission filters
  authorization_filter [ :read, :performance ], :space, :only => [ :index ]
  authorization_filter :update, :user, :only => [ :edit, :update ]
  authorization_filter :delete, :user, :only => [ :destroy ]

  set_params_from_atom :user, :only => [ :create, :update ]

  # GET /users
  # GET /users.xml
  # GET /users.atom
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
      format.atom
    end

  end

  # GET /users/1
  # GET /users/1.xml
  # GET /users/1.atom
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
      format.atom
      format.atomsvc
    end
  end

  #This method returns the user to show the form to edit himself
  def edit
    @shib_user = session.has_key?(:shib_data)
    @shib_provider = session[:shib_data]["Shib-Identity-Provider"] if @shib_user
    render :layout => 'no_sidebar'
  end

  def clean
    render :update do |page|
      page.replace_html 'search_results', ""
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  # PUT /users/1.atom
  #this method updates a user
  def update
    respond_to do |format|
      if user.update_attributes(params[:user])
        user.tag_with(params[:tags]) if params[:tags]

        flash[:success] = t('user.updated')
        format.html { #the superuser will be redirected to list_users
          redirect_to(user_path(@user))
        }
        format.xml  { render :xml => @user }
        format.atom { head :ok }
      else
        format.html { render :action => "edit", :layout => "no_sidebar" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
        format.atom { render :xml => @user.errors.to_xml, :status => :not_acceptable }
      end
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
  # DELETE /users/1.atom
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
      format.atom { head :ok }
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
      format.atom { head :ok }
    end
  end

  def resend_confirmation
    if params[:email]
      @user = User.find_by_email(params[:email])
      unless @user
        flash[:error] = t(:could_not_find_anybody_with_that_email_address)
        return
      end
      if @user.activated_at
        flash[:notice] = t('user.resend_confirmation_email.already_confirmed', :email => @user.email)
      else
        Notifier.delay.confirmation_email(@user)
        flash[:notice] = t('user.resend_confirmation_email.success', :email => @user.email)
        redirect_to root_path
      end
    end
  end

end
