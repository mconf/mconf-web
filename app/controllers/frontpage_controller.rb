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

class FrontpageController < ApplicationController

  def index
    # @relevant_users = User.find(:all).sort_by{|user| user.posts.size}.reverse.first(4)
    # @recent_spaces = Space.find(:all, :conditions => {:public => true},:order => "created_at Desc").first(3)
    # @recent_events = Event.find(:all, :order => "start_date Desc").select{|p| !p.space.disabled? && p.space.public? &&  p.start_date && p.start_date.future?}.first(2)
    # @recent_posts = Post.find(:all, :conditions => {:parent_id => nil}, :order => "created_at Desc").select{|p| !p.space.disabled? && p.space.public == true}.first(2)
    # @recent_spaces = Space.where(:public => true).order("created_at Desc").first(4)

    @stats = {}
    @stats[:users] = User.count
    @stats[:spaces] = Space.count
    @stats[:events] = Event.count

    # TODO
    @webconferences_count =
      Statistic.where(['url LIKE ?', '/join']).order('unique_pageviews desc').count

    # Find the public spaces that have most pageviews
    @most_active_spaces = []
    Statistic.where(['url LIKE ?', '/spaces/%']).order('unique_pageviews desc').each do |rec|
      perma = rec.url.split("/").last
      space = Space.find_by_permalink(perma)
      @most_active_spaces << space if space.public?
      break if @most_active_spaces.size == 8
    end

    respond_to do |format|
      if logged_in?
        format.html { redirect_to home_path}
      else
        format.html # index.html.erb
        format.xml  { render :xml => @spaces }
        format.atom
      end
    end
  end

end
