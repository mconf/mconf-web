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

class GroupsController < ApplicationController
  before_filter :space!

  authorization_filter [ :manage, :group ], :space , :only => [:edit, :update, :destroy]
  
  def index
    if params[:space_id]
      @users = @space.actors.sort {|x,y| x.name <=> y.name }
      @groups = @space.groups.all(:order => "name ASC")
      @users_without_group = @users.select{|u| u.groups.select{|g| g.space==@space}.empty?}
      if params[:edit_group]
        @editing_group = @space.groups.find(params[:edit_group])
      else
        @editing_group = Group.new()
      end
    end
  end
  
  def create
    #if mailing list is disabled, the param :mailing_list is removed
    if params[:mail].blank?
      params[:group][:mailing_list] = ""
    end
      
    @group = @space.groups.build(params[:group])
    
    if @group.save
      respond_to do |format|
      format.html {
        flash[:success] = t('group.created', :name => @group.name)
        redirect_to request.referer
      }
      end
    else
      flash[:error] = t('group.not_valid')
      redirect_to request.referer
    end
  end
  
  def edit
    redirect_to space_groups_path(@space, :edit_group => params[:id], :admin => params[:admin])
  end
  
  def update
    
    @group = @space.groups.find(params[:id])
    
    if params[:mail].blank?
      params[:group][:mailing_list] = ""
    end
    if params[:add_user]
      @group.user_ids += [params[:add_user]]
      @group.user_ids.uniq!
      result = @group.save
    else
      result = @group.update_attributes(params[:group])
    end
        
    if result
      respond_to do |format|
      format.html {
      flash[:success] = t('group.updated', :name => @group.name)
        redirect_to request.referer
      }
      end
    else
      message = ""
      @group.errors.full_messages.each {|msg| message += msg + "  <br/>"}
      flash[:error] = message
      redirect_to request.referer
    end
  end
  
  def destroy
    group = @space.groups.find(params[:id])
    if group.destroy
    respond_to do |format|
      format.html {
        flash[:success] = t('group.deleted', :name => group.name)
        redirect_to request.referer
      }
      end
    else
      flash[:error] = t('group.not_deleted', :name => group.name)
      redirect_to request.referer
    end
  end
end
