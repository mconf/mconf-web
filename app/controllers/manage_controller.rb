# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ManageController < ApplicationController
  authorize_resource :class => false

  def users
    @users = User.find_with_disabled(:all,:order => "username")
                 .paginate(:page => params[:page], :per_page => 20)
    @site_roles = Site.roles
  end

  def spaces
    @spaces = Space.find_with_disabled(:all,:order => "name").paginate(:page => params[:page], :per_page => 20)
  end

  def spam
    @spam_events= Event.find(:all, :conditions => {:spam => true})
    @spam_posts = Post.find(:all, :conditions => {:spam => true})
  end

end
