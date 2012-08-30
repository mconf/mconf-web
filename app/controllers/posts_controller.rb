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

class PostsController < ApplicationController
  # Include basic Resource methods
  # See documentation: ActionController::StationResources

  layout "spaces_show"
  include ActionController::StationResources
  include SpamControllerModule

  # Posts needs a Space. It will respond 404 if no space if found
  before_filter :space!
  before_filter :webconf_room!

  before_filter :post, :except => [ :index, :new, :create]

  authorization_filter [ :read, :content ],   :space, :only => [ :index ]
  authorization_filter [ :create, :content ], :space, :only => [ :new, :create ]
  authorization_filter :read,   :post, :only => [ :show ]
  authorization_filter :update, :post, :only => [ :edit, :update ]
  authorization_filter :delete, :post, :only => [ :destroy ]

  def index
    # AtomPub feeds are ordered by updated_at
    if request.format == Mime::ATOM
      params[:order], params[:direction] = "updated_at", "DESC"
    end

    posts

    respond_to do |format|
      format.html
      format.atom
      format.xml { render :xml => @posts }
    end
  end

  # Show this Entry
  #   GET /posts/:id
  def show
    if params[:last_page]
      post_comments(post, {:last => true})
    else
      post_comments(post)
    end

    respond_to do |format|
      format.html {
        # FIXME: this is wrong, VIEW code should go to app/views or app/helpers
        if request.xhr?
          if params[:edit]

            params[:form]='attachments'
            render :partial => "edit_post", :locals => { :post => post }
          else
            render :partial => "new_post", :locals => { :p_id=> @post.id, :id => "reply-form"}
          end
        end
      }
      format.xml { render :xml => @post.to_xml }
      format.json { render :json => @post.to_json }
    end
  end

  def reply_post
    @post_id = params[:id]
    respond_to do |format|
      format.html{
        render :partial => "reply_post"
      }
    end
  end

  # Renders form for editing this Entry metadata
  #   GET /posts/:id/edit
  def edit
    respond_to do |format|
      format.html {
        render :partial => "edit_post"
      }
    end
  end

  # create and update now in ActionController::StationResources

  # Delete this Entry
  #   DELETE /spaces/:id/posts/:id --> :method => delete
  #destroy de content of the post. Then its container(post) is destroyed automatic.
  def destroy
    @post.destroy
    respond_to do |format|
      if !@post.event.nil?
        flash[:notice] = t('post.deleted', :postname => @post.title)
        format.html {redirect_to space_event_path(@space, @post.event)}
      elsif @post.parent_id.nil?
        flash[:notice] = t('thread.deleted')
        format.html { redirect_to space_posts_path(@space) }
      else
        flash[:notice] = t('post.deleted', :postname => @post.title)
        format.html { redirect_to request.referer }
      end
      format.js
      format.xml { head :ok }
    end
  end

  private

  # DRY (used in index and create.js)
  def posts
    per_page = params[:extended] ? 6 : 15
    @posts ||= Post.roots.in(@space).not_events().find(:all,
                                                     :order => "updated_at DESC"
    ).paginate(:page => params[:page],
                                                              :per_page => per_page)

  end

  def post_comments(parent_post, options = {})
    total_posts = parent_post.children
    per_page = 5
    page = params[:page] || options[:last] && total_posts.size.to_f./(per_page).ceil
    page = nil if page == 0

    @posts ||= total_posts.paginate(:page => page, :per_page => per_page)
  end

  def after_create_with_success
    redirect_to(request.referer || space_posts_path(@space))
  end

  def after_create_with_errors
    # This should be in the view
    params[:form] = 'attachments' if @post.attachments.any?
    flash[:error] = @post.errors.to_xml
    posts
    render :index
    flash.delete([:error])
  end

  def after_update_with_success
    redirect_to(request.referer || space_posts_path(@space))
  end

  def after_update_with_errors
    # This should be in the view
    params[:form] = 'attachments' if @post.attachments.any?
    flash[:error] = @post.errors.to_xml
    posts
    render :index
    flash.delete([:error])
  end
end
