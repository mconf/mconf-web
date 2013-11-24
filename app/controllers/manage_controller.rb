# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ManageController < ApplicationController
  authorize_resource :class => false

  def users
    name = params[:q]
    partial = params.delete(:partial) # otherwise the pagination will include this param

    query = User.with_disabled.joins(:profile).includes(:profile).order("profiles.full_name")
    if name.blank?
      query = query.all
    else
      query = query.where("profiles.full_name like ? OR users.username like ? OR users.email like ?", "%#{name}%", "%#{name}%", "%#{name}%")
    end
    @users = query.paginate(:page => params[:page], :per_page => 20)

    if partial
      render :partial => 'users_list', :layout => false
    else
      render :layout => 'no_sidebar'
    end
  end

  def spaces
    @spaces = Space.find_with_disabled(:all,:order => "name").paginate(:page => params[:page], :per_page => 20)
  end

  def spam
    @spam_events = Event.where(:spam => true).all
    @spam_posts = Post.where(:spam => true).all
    render :layout => 'no_sidebar'
  end

end
