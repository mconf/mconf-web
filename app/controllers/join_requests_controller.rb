# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class JoinRequestsController < ApplicationController
  before_filter :space!
  before_filter :already_joined?, :only => [:new, :create]

  def new
    @join_request = space.join_requests.new
  end

  def create
    @join_request = space.join_requests.new(params[:join_request])
    @join_request.candidate = current_user
    @join_request.email = current_user.email
    @join_request.request_type = 'request'

    if @join_request.save
      flash[:notice] = t('join_request.created')
    else
      flash[:error] = t('join_request.already_sent')
      render :action => new
      return
      # TODO: identify errors for better usability
      # flash[:error] << @join_request.errors.to_xml
    end

    if space.public
      redirect_to space_path(space)
    else
      redirect_to spaces_path
    end
  end

  def update
    join_request.attributes = params[:join_request]
    join_request.introducer = current_user if join_request.recently_processed?

    respond_to do |format|
      if join_request.save
        format.html {
          flash[:success] = ( join_request.recently_processed? ?
                            ( join_request.accepted? ? t('join_request.accepted') : t('join_request.discarded') ) :
                            t('join_request.updated'))
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

  private

  def join_request
    @join_request ||= group.join_requests.find(params[:id])
  end

  def group
    @group ||= record_from_path(:acts_as => :stage)
  end

  def already_joined?
    if space.users.include?(current_user)
      flash[:notice] = t('join_request.joined')
      redirect_to space
      return
    elsif space.join_request_for?(current_user)
  end

end
