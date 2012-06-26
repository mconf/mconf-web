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

# Require Station Controller
require_dependency "#{ Rails.root.to_s }/vendor/plugins/station/app/controllers/sessions_controller"

class SessionsController
  # Don't render Station layout, use application layout instead
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
      if request.xhr?
        format.js {
          render :partial => "sessions/login"
        }
      end
      format.html { render :layout => "application_without_sidebar" }
      format.m
    end
  end

  private

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
