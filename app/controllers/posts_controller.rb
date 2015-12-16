# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PostsController < InheritedResources::Base

  belongs_to :space, finder: :find_by_permalink

  load_and_authorize_resource :space, :find_by => :permalink
  before_filter :get_posts, :only => [:index]
  load_and_authorize_resource :through => :space

  # need it to show info in the sidebar
  before_filter :webconf_room!, only: [:index, :show, :new, :edit], if: -> { set_layout == 'spaces_show' }

  before_filter :set_author, only: [:create]

  after_filter :only => [:update] do
    @post.new_activity :update, current_user unless @post.errors.any?
  end

  after_filter :only => [:create] do
    @post.new_activity (@post.parent.nil? ? :create : :reply), current_user unless @post.errors.any?
  end

  layout :set_layout
  def set_layout
    if [:new, :edit].include?(action_name.to_sym) && request.xhr?
      false
    else
      "spaces_show"
    end
  end

  def show
    if params[:last_page]
      post_comments(@post, {:last => true})
    else
      post_comments(@post)
    end

    show!
  end

  def create
    create! { space_posts_path(@space) }
  end

  def update
    update! { space_posts_path(@space) }
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

  def set_author
    @post.author = current_user
  end

  def get_posts
    per_page = params[:extended] ? 6 : 15
    @posts = @space.posts
      .order("updated_at DESC")
      .paginate(page: params[:page], per_page: per_page)
  end

  def post_comments(parent_post, options = {})
    total_posts = parent_post.children
    per_page = 5
    page = params[:page] || options[:last] && total_posts.size.to_f./(per_page).ceil
    page = nil if page == 0

    @posts ||= total_posts.paginate(:page => page, :per_page => per_page)
  end
end
