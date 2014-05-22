# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class JoinRequestsController < ApplicationController

  # Recent activity for join requests
  after_filter :only => [:update] do
    @space.new_activity :join, current_user unless @join_request.errors.any? || !@join_request.accepted?
  end

  load_resource :space, :find_by => :permalink
  load_and_authorize_resource :join_request, :through => :space, :except => [:index, :invite]
  load_resource :join_request, :through => :space, :only => [:index, :invite] # these two are authenticated via space parent

  before_filter :webconf_room!, :only => [:index, :show, :invite]

  respond_to :html

  layout :determine_layout

  def determine_layout
    case params[:action].to_sym
    when :index
      "spaces_show"
    when :new
      "no_sidebar"
    when :invite
      "spaces_show"
    else
      "spaces_show"
    end
  end

  def index
    authorize! :index_join_requests, @space
  end

  def show
  end

  def new
    if @space.users.include?(current_user)
      redirect_to space_path(@space)
    elsif @space.pending_join_request_for?(current_user)
      @already_requested = true
    else
      @already_requested = false
    end
  end

  def invite
    @join_request = JoinRequest.new
    authorize! :invite, @space
  end

  def create

    # if it's an admin creating new requests (inviting) for his space
    if params[:invite]
      # TODO: move this block of code to the a method in the model that creates all
      #   invitations an returns the errors already formatted to show in the views
      already_invited = []
      errors = []
      success = []
      ids = params[:candidates].split ',' || []
      ids.each do |id|
        user = User.find_by_id(id)
        jr = @space.join_requests.new(params[:join_request])
        if @space.pending_join_request_for?(user)
          already_invited << user.username
        elsif user
          jr.candidate = user
          jr.email = user.email
          jr.request_type = 'invite'
          jr.introducer = current_user
          if jr.save
            success.push jr.candidate.username
          else
            errors.push "#{jr.email}: #{jr.errors.full_messages.join(', ')}"
          end
        else
          errors.push t('join_requests.create.user_not_found', :id => id)
        end
      end
      unless errors.empty?
        flash[:error] = t('join_requests.create.error', :errors => errors.join(' - '))
      end
      unless success.empty?
        flash[:success] = t('join_requests.create.sent', :users => success.join(', '))
      end
      unless already_invited.empty?
        flash[:notice] = t('join_requests.create.already_invited', :users => already_invited.join(', '))
      end
      redirect_to invite_space_join_requests_path(@space)

    # it's a common user asking for membership in a space
    else
      if @space.pending_join_request_for?(current_user)
        flash[:notice] = t('join_requests.create.duplicated')
        if @space.public
          redirect_to space_path(@space)
        else
          redirect_to spaces_path
        end
      else
        @join_request = @space.join_requests.new(params[:join_request])
        @join_request.candidate = current_user
        @join_request.email = current_user.email
        @join_request.request_type = 'request'

        if @join_request.save
          flash[:notice] = t('join_requests.create.created')
          if @space.public
            redirect_to space_path(@space)
          else
            redirect_to spaces_path
          end
        else
          flash[:error] = t('join_requests.create.error', :errors => @join_request.errors.full_messages.join(', '))
          redirect_to new_space_join_request_path(@space)
        end
      end

    end
  end

  def update

    # Admin doing the approval of a request
    if @join_request.request_type == 'request' && authorize!(:approve, @join_request)
      @join_request.introducer = current_user if @join_request.recently_processed?
      @join_request.attributes = params[:join_request]
    # User accepting the invitation
    elsif @join_request.request_type == 'invite' && authorize!(:accept, @join_request)
      @join_request.attributes = params[:join_request].except(:role)
    end

    respond_to do |format|
      if @join_request.save
        format.html {
          flash[:success] = ( @join_request.recently_processed? ?
                            ( @join_request.accepted? ? t('join_requests.update.accepted') :
                            t('join_requests.update.discarded') ) :
                            t('join_requests.update.updated'))
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

  def destroy
    @join_request.destroy

    respond_to do |format|
      format.html {
        redirect_to request.referer
      }
    end
  end

end
