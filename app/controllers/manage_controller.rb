# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ManageController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource :class => false

  def users
    words = params[:q].try(:split, /\s+/)
    query = User.with_disabled.search_by_terms(words, can?(:manage, User)).search_order

    [:disabled, :approved, :can_record].each do |filter|
      if !params[filter].nil?
        val = (params[filter] == 'true') ? true : [false, nil]
        query = query.where(filter => val)
      end
    end

    auth_methods = []
    auth_methods << :shibboleth if params[:login_method_shib] == 'true'
    auth_methods << :ldap if params[:login_method_ldap] == 'true'
    auth_methods << :local if params[:login_method_local] == 'true'
    query = query.with_auth(auth_methods)

    if params[:admin].present?
      val = (params[:admin] == 'true') ? true : [false, nil]
      query = query.where(superuser: val)
    end

    @users = query.paginate(page: params[:page], per_page: 20)

    if request.xhr?
      render partial: 'users_list', layout: false
    else
      render layout: 'no_sidebar'
    end
  end

  def spaces
    words = params[:q].try(:split, /\s+/)
    query = Space.with_disabled.search_by_terms(words, can?(:manage, Space)).search_order

    # start applying filters
    [:disabled, :approved].each do |filter|
      if !params[filter].nil?
        val = (params[filter] == 'true') ? true : [false, nil]
        query = query.where(filter => val)
      end
    end

    @spaces = query.paginate(:page => params[:page], :per_page => 20)

    if request.xhr?
      render :partial => 'spaces_list', :layout => false, :locals => { :spaces => @spaces }
    else
      render :layout => 'no_sidebar'
    end
  end

  def recordings
    words = params[:q].try(:split, /\s+/)
    query = BigbluebuttonRecording.search_by_terms(words).search_order

    [:published, :available].each do |filter|
      if !params[filter].nil?
        val = (params[filter] == 'true') ? true : [false, nil]
        query = query.where(filter => val)
      end
    end

    if params[:playback] == "true"
      query = query.has_playback
    elsif params[:playback] == "false"
      query = query.no_playback
    end

    @recordings = query.paginate(page: params[:page], per_page: 20)

    if request.xhr?
      render partial: 'recordings_list', layout: false, locals: { recordings: @recordings }
    else
      render layout: 'no_sidebar'
    end
  end

end
