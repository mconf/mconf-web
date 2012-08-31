# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class FrontpageController < ApplicationController

  layout 'clean'

  def show
    # @relevant_users = User.find(:all).sort_by{|user| user.posts.size}.reverse.first(4)
    # @recent_spaces = Space.find(:all, :conditions => {:public => true},:order => "created_at Desc").first(3)
    # @recent_events = Event.find(:all, :order => "start_date Desc").select{|p| !p.space.disabled? && p.space.public? &&  p.start_date && p.start_date.future?}.first(2)
    # @recent_posts = Post.find(:all, :conditions => {:parent_id => nil}, :order => "created_at Desc").select{|p| !p.space.disabled? && p.space.public == true}.first(2)
    # @recent_spaces = Space.where(:public => true).order("created_at Desc").first(4)

    # Find the public spaces that have most pageviews
    # @most_active_spaces = []
    # Statistic.where(['url LIKE ?', '/spaces/%']).order('unique_pageviews desc').each do |rec|
    #   perma = rec.url.split("/").last
    #   space = Space.find_by_permalink(perma)
    #   @most_active_spaces << space if space and space.public?
    #   break if @most_active_spaces.size == 10
    # end

   respond_to do |format|
      if user_signed_in?
        format.html { redirect_to home_path }
      else
        format.html
      end
    end
  end

end
