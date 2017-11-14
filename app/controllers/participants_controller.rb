# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ParticipantsController < InheritedResources::Base
  respond_to :html

  before_filter :require_events_mod

  layout "no_sidebar", only: [:new, :create]

  load_and_authorize_resource :event, find_by: :slug
  load_and_authorize_resource :participant, :through => :event

  belongs_to :event, finder: :find_by_slug

  before_filter :custom_loading, only: [:index]
  before_filter only: [:create] do
    if verify_captcha == false
      flash[:error] = I18n.t('recaptcha.errors.verification_failed')
      render :new
    end
  end

  after_filter only: [:create] do
    @participant.new_activity(params[:action], current_user) if @participant.persisted?
  end

  after_filter :waiting_for_confirmation_message, only: [:create]

  def create
    @participant.event = @event
    if current_user
      @participant.owner = current_user
      @participant.email = current_user.email
    end

    respond_to do |format|
      # If user is already registered with this email succeed with another message and don't save
      taken = @participant.email_taken?
      notice = taken ? t('flash.participants.create.already_created') : t('flash.participants.create.notice')
      if taken || @participant.save
        format.html { redirect_to @event, notice: notice }
        format.json { render json: @participant, status: :created, location: @participant }
      else
        flash[:error] = t('flash.participants.create.alert')
        format.html { render action: "new" }
        format.json { render json: @participant.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @participant.destroy
    destroy! { can?(:update, @event) ? request.referer : event_path(@event) }
  end

  private
  def participant_params
    params.require(:participant).permit(:email, :event, :event_id, :owner, :owner_id)
  end

  private

  def custom_loading
    @participants = @participants.accessible_by(current_ability)
      .order(['owner_id desc', 'created_at desc'])
      .paginate(:page => params[:page])
  end

  def handle_access_denied(exception)
    if @event.owner.nil?
      raise ActiveRecord::RecordNotFound
    else
      raise exception
    end
  end

  def waiting_for_confirmation_message
    if @participant.persisted? && !@participant.email_confirmed?
      flash[:notice] = t('flash.participants.create.waiting_confirmation')
    end
  end

end
