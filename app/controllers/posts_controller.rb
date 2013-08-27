# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PostsController < ApplicationController

  include SpamControllerModule

  layout "spaces_show"

  # Posts needs a Space. It will respond 404 if no space if found
  before_filter :space!
  before_filter :webconf_room!
  before_filter :get_posts, :only => [:index]

  load_and_authorize_resource :space, :find_by => :permalink
  load_and_authorize_resource :through => :space
  skip_load_resource :only => :index

  def index
    @post = Post.new

    respond_to do |format|
      format.html
    end
  end

  def show
    if params[:last_page]
      post_comments(post, {:last => true})
    else
      post_comments(post)
    end

    respond_to do |format|
      format.html
    end
  end

  def new
    @post = Post.new
  end

  def create
    @post = Post.new(params[:post])
    @post.space = @space
    @post.author = current_user

    respond_to do |format|
      if @post.save
        flash[:success] = t('post.created')
        format.html { redirect_to request.referer }

        @post.create_activity :create, :owner => @space,
          :parameters => {
            :title => @post.title,
            :username => @post.author.name,
            :user_id  => @post.author.id
          }
      else
        flash[:error] = t('post.error.create')
        format.html { redirect_to request.referer }
      end
    end

  end

  def update
    @post = @space.posts.find(params[:id])
      if @post.update_attributes(params[:post])
        respond_to do |format|
          format.html {
            flash[:success] = t('post.updated')
            redirect_to space_posts_index_path(@space)
          }
      end

      @post.create_activity :update, :owner => @space,
          :parameters => {
            :title => @post.title,
            :username => @post.author.name,
            :user_id  => @post.author.id
          }

    else
      flash[:error] = t('post.error.update')
      redirect_to space_posts_index_path(@space)
    end
  end

  def reply_post
    respond_to do |format|
      format.html {
        render :partial => "reply_post"
      }
    end

    @post.create_activity :reply, :owner => @space,
          :parameters => {
            :title => @post.title,
            :username => @post.author.name,
            :user_id  => @post.author.id
          }
  end

  def edit
    respond_to do |format|
      format.html {
        render :partial => "edit_post"
      }
    end
  end

  # Destroys de content of the post. Then its container(post) is
  # destroyed automatically.
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
    end
  end

  private

  def get_posts
    per_page = params[:extended] ? 6 : 15
    @posts = @space.posts
      .order("updated_at DESC")
      .paginate(:page => params[:page], :per_page => per_page)
  end

  def post_comments(parent_post, options = {})
    total_posts = parent_post.children
    per_page = 5
    page = params[:page] || options[:last] && total_posts.size.to_f./(per_page).ceil
    page = nil if page == 0

    @posts ||= total_posts.paginate(:page => page, :per_page => per_page)
  end

  # TODO: these error/success methods were not properly tested

  def after_create_with_success
    redirect_to(request.referer || space_posts_path(@space))
  end

  def after_create_with_errors
    # This should be in the view
    params[:form] = 'attachments' if @post.attachments.any?
    flash[:error] = @post.errors.to_xml
    get_posts
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
