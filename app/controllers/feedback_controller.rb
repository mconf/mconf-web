# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class FeedbackController < ApplicationController

  def webconf
    feedback_url = current_site.feedback_url
    unless feedback_url.blank?
      redirect_to feedback_url
    else
      render :webconf, :layout => "no_sidebar"
    end
  end

  def new
    render :layout => false if request.xhr?
  end

  def create
    @feedback = Feedback.new(params[:feedback])

    if @feedback.valid?
      ApplicationMailer.feedback_email(@feedback.from, @feedback.subject, @feedback.message).deliver
      flash[:success] = t('feedback.create.success')
    elsif @feedback.errors.include?(:from)
      flash[:error] = t('feedback.create.check_mail')
    else
      flash[:error] = t('feedback.create.fill_fields')
    end

    redirect_to :back
  end
end
