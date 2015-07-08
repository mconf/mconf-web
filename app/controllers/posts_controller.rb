# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PostsController < ApplicationController
  include SpamControllerModule

  before_filter :authenticate_user!, except: [:index, :show]

  layout "spaces_show"

  after_filter :only => [:update] do
    @post.new_activity :update, current_user unless @post.errors.any?
  end

  after_filter :only => [:create] do
    @post.new_activity (@post.parent.nil? ? :create : :reply), current_user unless @post.errors.any?
  end

  load_and_authorize_resource :space, :find_by => :permalink
  load_and_authorize_resource :through => :space

  # need it to show info in the sidebar
  before_filter :webconf_room!

  before_filter :get_posts, :only => [:index]
  skip_load_resource :only => :index

  def index
    @post = Post.new

    respond_to do |format|
      format.html
    end
  end

  def show
    if params[:last_page]
      post_comments(@post, {:last => true})
    else
      post_comments(@post)
    end

    respond_to do |format|
      format.html
    end
  end

  def new
    respond_to do |format|
      format.html {
        render :partial => "new_post"
      }
    end
  end

  def create
    @post = Post.new(post_params)
    @post.space = @space
    @post.author = current_user

    respond_to do |format|
      if @post.save
        flash[:success] = t('post.created')
        format.html { redirect_to request.referer }
      else
        flash[:error] = t('post.error.create')
        format.html { redirect_to request.referer }
      end
    end

  end

  def update
    if @post.update_attributes(post_params)
      respond_to do |format|
        format.html {
          flash[:success] = t('post.updated')
          redirect_to space_posts_path(@space)
        }
      end
    else
      flash[:error] = t('post.error.update')
      redirect_to space_posts_path(@space)
    end
  end

  def edit
    respond_to do |format|
      format.html {
        render :partial => "edit_post"
      }
    end
  end

  # Destroys the content of the post. Then its container(post) is
  # destroyed automatically.
  def destroy
    @post.destroy
    respond_to do |format|
      if @post.parent_id.nil?
        flash[:notice] = t('thread.deleted')
        format.html { redirect_to space_posts_path(@space) }
      else
        flash[:notice] = t('post.deleted', :postname => @post.title)
        format.html { redirect_to request.referer }
      end
      format.js
    end
  end

  def reply_post
    respond_to do |format|
      format.html {
        render :partial => "reply_post"
      }
    end
  end

  allow_params_for :post
  def allowed_params
    [:title, :text, :parent_id]
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

  def resource_for_spam
    @post
  end

end
