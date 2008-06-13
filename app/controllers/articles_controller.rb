class ArticlesController < ApplicationController
  # Include some methods and set some default filters. 
  # See documentation: CMS::Controller::Contents#included
  include CMS::Controller::Contents

  # Articles list may belong to a container
  # /articles
  # /:container_type/:container_id/articles
  before_filter :get_container, :only => [ :index  ]

  # Needs a Container when posting a new Article
  before_filter :needs_container, :only => [ :new, :create ]

  # Get Article in member actions
  before_filter :get_content, :except => [ :index, :new, :create ]

  before_filter :get_space, :only => [ :index, :new, :create ]
  before_filter :get_cloud

  protected
  def get_space
    @space = @container
  end
end
