# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class FeedbackController < ApplicationController
  before_filter :authenticate_user!, except: [:webconf]

  # modals
  before_filter :force_modal, only: :new

  layout :determine_layout

  def determine_layout
    case params[:action].to_sym
    when :new
      false
    else
      "no_sidebar"
    end
  end

  def webconf
    feedback_url = current_site.feedback_url
    unless feedback_url.blank?
      redirect_to feedback_url
    else
      render :webconf
    end
  end

  def new
  end

  def create
    @feedback = Feedback.new(params[:feedback])
    @feedback.from = current_user.email

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
