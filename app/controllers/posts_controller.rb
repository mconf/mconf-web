class PostsController < ApplicationController
  # Include some methods and filters. 
  include CMS::Controller::Posts
  
  # Actions different that reading need authentication
  before_filter :authentication_required, :except => [ :index, :show, :media ]
  
  # Posts list may belong to a container
  # /posts
  # /:container_type/:container_id/posts
  before_filter :get_container, :only   => [ :index ]
         before_filter :get_cloud
  # Get Post in member actions
  before_filter :get_post, :except => [ :index, :new, :create ]
  
  # Post media management needs Content supporting media
  before_filter :post_has_media, :only => [ :media, :edit_media ]
before_filter :is_public_space, :only=>[:index]
  before_filter :get_space_from_container, :only => [ :index, :new, :create ]
  before_filter :get_space_from_post, :only => [ :show, :edit, :update ]

  before_filter :get_public_posts, :only => [:index,:show]
# before_filter :space_member, :only=>[:index, :show]
  before_filter :redirect_to_comment, :only => [ :show ]

  private
  def redirect_to_comment
    redirect_to(post_path(@post.container, :anchor => "cms_post_#{ @post.id }")) if @post.container.is_a?(CMS::Post)
  end

  def get_space_from_container
    session[:current_tab] = "Posts" 
    @space = @container
  end
  
  def get_space_from_post
    session[:current_tab] = "Posts" 
    @space = @post.container
  end
end
