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

class FeedbackController < ApplicationController

  def webconf
    feedback_url = Site.current.feedback_url
    unless feedback_url.blank?
      redirect_to feedback_url
    else
      render :webconf, :layout => "no_sidebar"
    end
  end

  def new
    if request.xhr?
      render :layout => false
    end
  end

  def create
    if (params[:subject].present? and params[:from].present? and params[:body].present?)
      if (params[:from]).match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
        Notifier.delay.feedback_email(params[:from],params[:subject], params[:body] )
        respond_to do |format|
          format.html {
            flash[:success] = t('feedback.sent')
            redirect_to root_path()
          }
        end
      else
        respond_to do |format|
          format.html {
            flash[:error] = t('check_mail')
            render :action => "new"
          }
        end
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = t('fill_fields')
          render :action => "new"
        }
      end
    end
  end
end
