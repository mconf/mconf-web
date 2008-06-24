
class HomeController < ApplicationController  
   include CMS::Controller::Base
   before_filter :get_space
    before_filter :get_cloud
  def index
    session[:current_tab] = "Home"
    
    next_events
  end
  
  def index2
    redirect_to "/spaces/0"
  end
  
  def search
    #search in events in this space
    @query = params[:query]
    @even = CMS::Post.find_all_by_container_id_and_content_type(@container.id, "Event")
    @total, @results = Event.full_text_search(@query,:lazy => [:name, :description, :tag_list, :start_dates],  :page => (params[:page]||1))          
    @pages = pages_for(@total)
    @partials = []
    @events = []  
     if @results != nil
    @results.collect { |result|
      event = CMS::Post.find_by_content_type_and_content_id("Event", result.id)
      if @even.include?(event)
        @partials << event
      end
    }
    end
    if @partials != nil
    @partials.collect { |a|
      even = Event.find(a.content_id)
      @events << even
    }
    
    
    
    end
    
    #search users
    
     @use = User.find_by_contents(@query)
    @users = []
    i = 0
  
    @agen = @container.actors

    @use.collect { |user|
    # debugger
      if @agen.include?(user)
          @users << user
      end
     }

    #search posts
    
     @results = Article.find_by_contents(@query)
    @pos = @container.container_posts    
    @posts = []   
    @results.collect { |result|
      post = CMS::Post.find_by_content_type_and_content_id("CMS::Text", result.id)
      if @pos.include?(post)
        @posts << post
      end
    }
    
  end

  end