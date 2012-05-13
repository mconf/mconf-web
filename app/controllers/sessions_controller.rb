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

class SessionsController < ApplicationController
  layout :application_layout

  #after_filter :update_user   #this is used to remember when did he logged in or out the last time and update his/her home

  skip_before_filter :verify_authenticity_token

  # render new.rhtml
  def new
    if logged_in?
      flash[:error] = t('session.error.exist')
      redirect_to root_path
      return
    end

    # See ActionController::Sessions#authentication_methods_chain
    authentication_methods_chain(:new)

    respond_to do |format|
      format.html
      format.m
    end
  end


  #-#-# from station
  include ActionController::Sessions

  before_filter :save_location, :only => "new"

  # render new.rhtml
  def new
    authentication_methods_chain(:new)
  end

  def create
    if authentication_methods_chain(:create)
      respond_to do |format|
        format.html {
          redirect_back_or_default(after_create_path)
        }
        format.js
      end unless performed?
    else
      respond_to do |format|
        format.html {
          flash[:error] ||= t(:invalid_credentials)
          render(:action => "new")
        }
        format.js
      end unless performed?
    end
  end

  def destroy
    authentication_methods_chain(:destroy)

    reset_session

    return if performed?

    flash[:notice] = t(:logged_out)
    redirect_back_or_default(after_destroy_path)
  end

  private

  def after_create_path
    '/'
  end

  def after_destroy_path
    '/'
  end
  #-#-#

  def after_create_path
    if current_user.superuser == true && Site.current.new_record?
      flash[:notice] = t('session.error.fill')
      edit_site_path
    else
      home_path
    end
  end

  def after_destroy_path
    root_path
  end

  def update_user
    current_user.touch
  end

  def application_layout
    (request.format.to_sym == :m)? 'mobile.html' : 'application'
  end

end
