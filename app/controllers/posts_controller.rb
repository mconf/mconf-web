class PostsController < ApplicationController
  # Include some methods and filters. 
  include CMS::Controller::Posts
  
  # Actions different that reading need authentication
  before_filter :authentication_required, :except => [ :index, :show, :media ]
  
  # Posts list may belong to a container
  # /posts
  # /:container_type/:container_id/posts
  before_filter :get_container, :only   => [ :index ]
        
  # Get Post in member actions
  before_filter :get_post, :except => [ :index, :new, :create ]
  
  # Post media management needs Content supporting media
  before_filter :post_has_media, :only => [ :media, :edit_media ]
  
  
  # Redefine your actions here:
  # def index
  #   your stuff
  # end
end
