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

  load_and_authorize_resource :space, :find_by => :permalink, :except => [:new, :create]
  load_and_authorize_resource :through => :space

  before_filter :webconf_room!, :only => [:new, :index]

  def index
    render :layout => 'spaces_show'
  end

  def new
    # @join_request = space.join_requests.new
    @user_is_admin = space.role_for?(current_user, :name => 'Admin')

    # If it's the admin inviting, list the invitable users
    if @user_is_admin
      @users = (User.all - space.users)
      @checked_users = []
      render :layout => 'spaces_show'
    end
  end

  def create
    # If it's the admin creating a new request (inviting) for his space
    if space.role_for?(current_user, :name => 'Admin')
      @join_requests = []
      @ids = params[:candidates].split ',' || []
      @ids.each do |id|
        jr = space.join_requests.new(params[:join_request])
        user = User.find(id)
        jr.candidate = user
        jr.email = user.email
        jr.request_type = 'invite'
        jr.introducer = current_user
        @join_requests << jr
      end
      errors = []
      @join_requests.each { |jr| errors << [jr.email, jr.error_messages] if !jr.valid? }
      if errors.empty?
        @join_requests.each { |jr| jr.save(:validate => false) }
        flash[:notice] = t('join_requests.create.sent')
      else
        flash[:notice] = t('join_requests.create.error')
      end

      redirect_to new_space_join_request_path(space)
    else # It's a common user asking for membership in a space

      @join_request = space.join_requests.new(params[:join_request])
      @join_request.candidate = current_user
      @join_request.email = current_user.email
      @join_request.request_type = 'request'

      if @join_request.save
        flash[:notice] = t('join_requests.create.created')
      else
        flash[:error] = t('join_requests.create.error')
        # TODO: identify errors for better usability
        # flash[:error] << @join_request.errors.to_xml
      end

      if space.public
        redirect_to space_path(space)
      else
        redirect_to spaces_path
      end

    end

  end

  def update
    join_request.attributes = params[:join_request].except(:role)
    join_request.introducer = current_user if join_request.recently_processed?

    respond_to do |format|
      if join_request.save
        format.html {
          flash[:success] = ( join_request.recently_processed? ?
                            ( join_request.accepted? ? t('join_requests.update.accepted') :
                            t('join_requests.update.discarded') ) :
                            t('join_requests.update.updated'))
          redirect_to request.referer
        }
        if join_request.accepted?
          role = Role.find(params[:join_request][:role_id])
          space.add_member!(join_request.candidate, role.name)
          success = space.save
        end
      else
        format.html {
          flash[:error] = join_request.errors.to_xml
          redirect_to request.referer
        }
      end
    end
  end

  def destroy
    join_request.destroy

    respond_to do |format|
      format.html {
        redirect_to request.referer
      }
    end
  end

  private

  def join_request
    @join_request ||= @space.join_requests.find(params[:id])
  end

end
