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

class JoinRequestsController < ApplicationController
  before_filter :space!

  def new
    respond_to do |format|
      format.html{
        if request.xhr?
          render :layout => false
        end
      }
    end
  end

  def create

    # unless authenticated?
    #   unless params[:user]
    #     respond_to do |format|
    #       format.html {
    #         render :action => 'new'
    #       }
    #       format.js
    #     end
    #     return
    #   end

    #   if params[:register]
    #     cookies.delete :auth_token
    #     @user = User.new(params[:user])
    #     unless @user.save_with_captcha
    #       message = ""
    #       @user.errors.full_messages.each {|msg| message += msg + "  <br/> "}
    #       flash[:error] = message
    #       respond_to do |format|
    #         format.html {
    #           render :action => 'new'
    #         }
    #         format.js
    #       end
    #       return
    #     end
    #   end
    #   self.current_agent = User.authenticate_with_login_and_password(params[:user][:email], params[:user][:password])
    #   unless user_signed_in?
    #     flash[:error] = t('error.credentials')
    #     respond_to do |format|
    #       format.html {
    #         render :action => 'new'
    #       }
    #       format.js
    #     end
    #     return
    #   end
    # end

    if space.users.include?(current_user)

      flash[:notice] = t('join_request.joined')
      if request.xhr?
        render :partial => "redirect", :formats => [:js], :locals => {:url => space_path(space)}
      else
        redirect_to space
      end
      return
    end

    @join_request = space.join_requests.new(params[:join_request])
    @join_request.candidate = current_user

    if @join_request.save
      flash[:notice] = t('join_request.created')
    else

      flash[:error] = t('join_request.already_sent')
      # TODO: identify errors for better usability
      # flash[:error] << @join_request.errors.to_xml
    end

    if request.xhr?
      if space.public
        render :partial => "redirect", :formats => [:js], :locals => {:url => space_path(space)}
      else
        render :partial => "redirect", :formats => [:js], :locals => {:url => spaces_path}
      end
    else
      if space.public
        redirect_to space_path(space)
      else
        redirect_to spaces_path
      end
    end
  end

  #-#-# from station

  def create
    @join_request = group.join_requests.build params[:join_request]
    @join_request.candidate = current_user

    respond_to do |format|
      if @join_request.save
        format.html {
          flash[:notice] = t('join_request.created')
          redirect_to(root_path)
        }
      else
        flash[:error] = @join_requests.errors.to_xml
        redirect_to request.referer
      end
    end
  end

  def update
    join_request.attributes = params[:join_request]
    join_request.introducer = current_user if join_request.recently_processed?

    respond_to do |format|
      if join_request.save
        format.html {
          flash[:success] = ( join_request.recently_processed? ?
                            ( join_request.accepted? ? t('join_request.accepted') : t('join_request.discarded') ) :
                            t('join_request.updated'))
          redirect_to request.referer
        }
      else
        format.html {
          flash[:error] = @join_request.errors.to_xml
          redirect_to request.referer
        }
      end
    end
  end

  private

  def join_request
    @join_request ||= group.join_requests.find(params[:id])
  end

  def group
    @group ||= record_from_path(:acts_as => :stage)
  end

end
