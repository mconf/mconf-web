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
    query = User.with_disabled.search_by_terms(words, can?(:manage, User))

    # start applying filters
    [:disabled, :approved, :can_record].each do |filter|
      if !params[filter].nil?
        val = (params[filter] == 'true') ? true : [false, nil]
        query = query.where(filter => val)
      end
    end

    if params[:admin].present?
      val = (params[:admin] == 'true') ? true : [false, nil]
      query = query.where(superuser: val)
    end

    @users = query.paginate(:page => params[:page], :per_page => 20)

    if request.xhr?
      render :partial => 'users_list', :layout => false
    else
      render :layout => 'no_sidebar'
    end
  end

  def spaces
    name = params[:q]
    partial = params.delete(:partial) # otherwise the pagination links in the view will include this param

    query = Space.with_disabled.order("name")
    if name.present?
      query = query.where("name like ?", "%#{name}%")
    end
    @spaces = query.paginate(:page => params[:page], :per_page => 20)

    if request.xhr?
      render :partial => 'spaces_list', :layout => false, :locals => { :spaces => @spaces }
    else
      render :layout => 'no_sidebar'
    end
  end
end
