# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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
