# -*- coding: utf-8 -*-
# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

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
