# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class JoinRequestsController < ApplicationController
  before_filter :require_spaces_mod

  # Recent activity for join requests
  after_filter :only => [:accept, :decline] do
    @join_request.new_activity(params[:action]) if !@join_request.errors.any? && @join_request.persisted?
  end

  load_resource :space, :find_by => :slug
  load_and_authorize_resource :join_request, :find_by => :secret_token, :through => :space, :except => [:admissions, :invite]
  load_resource :join_request, :through => :space, :only => [:admissions, :invite] # these are authenticated via space parent

  before_filter :webconf_room!, only: [:admissions, :invite]
  before_filter :check_processed_request, only: [:accept, :decline]

  # only for :new because it has to redirect before :force_modal
  before_filter :check_already_member, only: [:new]

  # modals
  before_filter :force_modal, only: [:new, :invite]

  respond_to :html

  layout :determine_layout

  def determine_layout
    if [:new, :invite].include?(action_name.to_sym)
      false
    else
      'application'
    end
  end

  def admissions
    authorize! :manage_join_requests, @space
  end

  def new
    if @space.pending_join_request_or_invitation_for?(current_user)
      @pending_request = @space.pending_join_request_or_invitation_for(current_user)
    end
  end

  def invite
    @join_request = JoinRequest.new
    authorize! :manage_join_requests, @space
  end

  def create

    # if it's an admin creating new requests (inviting) for his space
    if params[:type] == 'invite' && can?(:manage_join_requests, @space)
      success, errors, already_invited = process_invitations

      unless errors.empty?
        flash[:error] = t('join_requests.create.error', :errors => errors.join(' - '))
      end
      unless success.empty?
        flash[:success] = t('join_requests.create.sent', :users => success.join(', '))
      end
      unless already_invited.empty?
        flash[:notice] = t('join_requests.create.already_invited', :users => already_invited.join(', '))
      end
      redirect_to admissions_space_join_requests_path(@space)

    # if it's a global admin adding people to the space
    elsif params[:type] == 'add' && can?(:add, @space)
      success, errors = process_additions
      unless errors.empty?
        flash[:error] = t('join_requests.create.error', errors: errors.join(' - '))
      end
      unless success.empty?
        flash[:success] = t('join_requests.create.users_added', users: success.join(', '))
      end
      redirect_to admissions_space_join_requests_path(@space)

    # it's a common user asking for membership in a space
    else
      if current_user.member_of?(@space)
        flash[:notice] = t('join_requests.create.you_are_already_a_member')
        redirect_after_created
      elsif @space.pending_join_request_or_invitation_for?(current_user)
        flash[:notice] = t('join_requests.create.duplicated')
        redirect_after_created
      else
        @join_request = @space.join_requests.new(join_request_params)
        @join_request.candidate = current_user
        @join_request.email = current_user.email
        @join_request.request_type = JoinRequest::TYPES[:request]

        if @join_request.save
          flash[:notice] = t('join_requests.create.created')
          redirect_after_created
        else
          flash[:error] = t('join_requests.create.error', :errors => @join_request.errors.full_messages.join(', '))
          redirect_to new_space_join_request_path(@space)
        end
      end

    end
  end

  def accept
    @join_request.accepted = true
    @join_request.processed = true
    @join_request.introducer = current_user if @join_request.is_request?

    # allow admins to set the role when accepting a join request
    if params[:admin].present? && can?(:manage_join_requests, @space)
      @join_request.role_id = Role.find_by_name("Admin").id
    end

    save_for_accept_and_decline t('join_requests.accept.accepted')
  end

  def decline
    # canceling a request/invitation means it will be destroyed, otherwise it is actually
    # marked as declined and kept in the database
    user_canceling_request = @join_request.is_request? && @join_request.candidate == current_user
    admin_canceling_invitation = @join_request.is_invite? &&
      @join_request.group.try(:is_a?, Space) && @join_request.group.admins.include?(current_user)
    destroy = user_canceling_request || admin_canceling_invitation

    if destroy
      @join_request.destroy
      respond_to do |format|
        format.html {
          if admin_canceling_invitation
            flash[:success] = t("join_requests.decline.invitation_destroyed")
          else
            flash[:success] = t("join_requests.decline.request_destroyed")
          end
          redirect_to :back
        }
      end
    else
      @join_request.accepted = false
      @join_request.processed = true
      @join_request.introducer = current_user if @join_request.is_request?
      save_for_accept_and_decline t('join_requests.decline.declined')
    end
  end

  private

  def redirect_after_created
    if @space.public || current_user.member_of?(@space)
      redirect_to space_path(@space)
    else
      redirect_to spaces_path
    end
  end

  def save_for_accept_and_decline(msg)
    respond_to do |format|
      if @join_request.save
        format.html {
          flash[:success] = msg
          if @join_request.is_invite?
            # a user accepting/declining an invitation he received
            redirect_to @join_request.accepted ? space_path(@space) : my_home_path
          else
            redirect_to request.referer
          end
        }
      else
        format.html {
          flash[:error] = @join_request.errors.full_messages.join(", ")
          redirect_to request.referer
        }
      end
    end
  end

  # If the join request was already processed, redirect the user somewhere or pretend it doesn't exist
  def check_processed_request
    if @join_request.processed?
      if @join_request.accepted
        redirect_to space_path(@space)
      else
        # pretend the join request doesn't exist
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  # If the user is already a member of the space, redirect to the space
  def check_already_member
    redirect_to space_path(@space) if current_user.member_of?(@space)
  end

  def process_additions
    errors = []
    success = []
    ids = params[:candidates].try(:split, ',') || []
    ids.each do |id|
      user = User.find_by_id(id)
      # New JoinRequest corresponding to this addition
      jr = @space.join_requests.new(join_request_params)
      if user
        jr.candidate = user
        jr.email = user.email
        jr.request_type = JoinRequest::TYPES[:no_accept]
        jr.introducer = current_user
        jr.accepted = true
        jr.processed = true
      end

      if @space.pending_join_request_or_invitation_for?(user)
        # Need to mark the old JoinRequest as processed to avoid
        # uniqueness conflicts that prevent the creation of the new JoinRequest
        old_jr = @space.pending_join_request_or_invitation_for(user)
        old_jr.processed = true
        old_jr.save

        if jr.save
          success.push jr.candidate.username
        else
          errors.push "#{jr.email}: #{jr.errors.full_messages.join(', ')}"
        end
      elsif @space.users.include?(user)
        errors.push t('join_requests.create.already_a_member', name: user.username)
      elsif user
        if jr.save
          success.push jr.candidate.username
        else
          errors.push "#{jr.email}: #{jr.errors.full_messages.join(', ')}"
        end
      else
        errors.push t('join_requests.create.user_not_found', id: id)
      end
    end
    [success, errors]
  end

  def process_invitations
    already_invited = []
    errors = []
    success = []
    ids = params[:candidates].try(:split, ',') || []
    ids.each do |id|
      user = User.find_by_id(id)
      jr = @space.join_requests.new(join_request_params)
      if @space.pending_join_request_or_invitation_for?(user)
        already_invited << user.username
      elsif @space.users.include?(user)
        errors.push t('join_requests.create.already_a_member', :name => user.username)
      elsif user
        jr.candidate = user
        jr.email = user.email
        jr.request_type = JoinRequest::TYPES[:invite]
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

    [success, errors, already_invited]
  end

  # Custom handler for access denied errors, overrides method on ApplicationController.
  def handle_access_denied exception
    if [:new, :manage_join_requests, :show].include? exception.action
      if user_signed_in?
        render_403 exception
      else
        redirect_to login_path
      end
    else
      raise exception
    end
  end

  allow_params_for :join_request
  def allowed_params
    is_space_admin = @space.present? && can?(:manage_join_requests, @space)
    if params[:action] == "create"
      if is_space_admin
        [ :role_id, :comment ]
      else
        [ :comment ]
      end
    else
      [ ]
    end
  end

end
