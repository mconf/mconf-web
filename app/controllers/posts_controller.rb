# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PostsController < InheritedResources::Base
  before_filter :require_spaces_mod

  belongs_to :space, finder: :find_by_slug

  load_and_authorize_resource :space, :find_by => :slug
  before_filter :get_posts, :only => [:index]
  load_and_authorize_resource :through => :space

  before_filter :set_author, only: [:create]

  after_filter only: :update do
    @post.new_activity :update, current_user unless @post.errors.any?
  end

  after_filter only: :create do
    @post.new_activity (@post.parent.nil? ? :create : :reply), current_user unless @post.errors.any?
  end

  # modals
  before_filter :force_modal, only: [:new, :edit, :reply_post]

  layout :determine_layout

  def determine_layout
    if [:new, :edit, :reply_post].include?(action_name.to_sym)
      false
    else
      "application"
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
    create! { |success, failure| create_update_handler(success, failure) }
  end

  def update
    update! { |success, failure| create_update_handler(success, failure) }
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
    @new_post = @space.posts.build(parent_id: @post.id)
    respond_to do |format|
      format.html {
        render partial: "reply_post"
      }
    end
  end

  allow_params_for :post
  def allowed_params
    [:title, :text, :parent_id]
  end

  private

  def create_update_handler success, failure
    success.html { redirect_to space_posts_path(@space) }
    failure.html {
      redirect_to space_posts_path(@space), flash: {
        error: I18n.t("flash.posts.#{action_name}.failure", errors: @post.errors.full_messages.join(', '))
      }
    }
  end

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
