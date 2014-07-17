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
    if params[:feedback].present? and
        params[:feedback][:subject].present? and
        params[:feedback][:from].present? and
        params[:feedback][:message].present?
      if valid_email? params[:feedback][:from]
        ApplicationMailer.feedback_email(params[:feedback][:from], params[:feedback][:subject], params[:feedback][:message]).deliver
        respond_to do |format|
          format.html {
            flash[:success] = t('feedback.create.success')
            redirect_to :back
          }
        end
      else
        respond_to do |format|
          format.html {
            flash[:error] = t('feedback.create.check_mail')
            redirect_to :back
          }
        end
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = t('feedback.create.fill_fields')
          redirect_to :back
        }
      end
    end
  end
end
