class SearchController < ApplicationController
  
  
  def all    
    @events = search_events(params)
    @users = search_users(params)
    @posts = search_posts(params)
    respond_to do |format|        
      format.html     
    end
  end
  
  def events
    search_events(params)
    
    respond_to do |format|        
      format.html     
    end
    
  end 
  
  
  def posts
    search_posts(params)
    
    respond_to do |format|   
      format.html
      format.js 
    end
  end
  
  def users
    search_users(params)
    respond_to do |format|        
      format.html     
    end
  end

  def tag
    
    @tag = Tag.find_by_name(params[:tag])
    @users = @tag.taggings.all(:conditions => [ "taggable_type = ?", "User" ]).map{ |t| 
      User.find(t.taggable_id) 
    }

    @events = @tag.taggings.all(:conditions => [ "taggable_type = ?", "Event" ]).map{ |t| 
      Event.find(t.taggable_id) 
    }

    @posts = @tag.taggings.all(:conditions => [ "taggable_type = ?", "Post" ]).map{ |t| 
      Post.find(t.taggable_id)
    }
    @query = params[:tag]
    respond_to do |format|        
      format.html     
    end
  end
  
  
  private
  
  def search_events(params)
    if params[:query]
      @query = params[:query]
      @search = Ultrasphinx::Search.new(:query => @query, :class_names => 'Event')
      @search.run
      @events = @search.results.select{|event| event.space == @space}
    end
    
    if params[:title]
      @query = params[:title]
      @search = Ultrasphinx::Search.new(:class_names => 'Event', :filters => {'name' => @query})
      @search.run
      @events = @search.results.select{|event| event.space == @space}
    end
    
    if params[:description]
      @query = params[:description]
      @search = Ultrasphinx::Search.new(:class_names => 'Event', :filters => {'description' => @query})
      @search.run
      @events = @search.results.select{|event| event.space == @space}
    end
    
    if params[:time1] && params[:time2]
      @query1 = params[:time1]
      @query2 = params[:time2]
      date1 = Date.parse(@query1)
      date1ok =  date1.strftime("%Y%m%d")
      date2 = Date.parse(@query2)
      date2ok =  date2.strftime("%Y%m%d")
      if date1ok > date2ok
        flash[:notice] = 'The first date cannot be lower than the second one'
        render :template => "events/search"
      else
      @filters = {'event_datetime_start_date' => @query1..@query2,'event_datetime_end_date' => @query1..@query2}
      @search = Ultrasphinx::Search.new(:class_names => 'Event',:filters => @filters)
      @search.run
      @events= @search.results.select{|event| event.space == @space}
      @query = ""
      end
    end
    @events
  end
  
  def search_posts (params)
    
    @query = params[:query] 
    @search = Ultrasphinx::Search.new(:query => @query, :class_names => 'Post')
    @search.run
    if @space.id == 1
      @posts = @search.results.select{|post| post!=nil && post.parent_id == nil}.sort_by{|e| e.updated_at}.reverse
    else  
      @posts = @search.results.select{|post| post!=nil && post.parent_id == nil && post.space == @space}.sort_by{|e| e.updated_at}.reverse
    end
    
    
  end
  
  def search_users (params)
    @query = params[:query]
    
    @search = Ultrasphinx::Search.new(:query => @query, :class_names => 'User')
    @search.run
    if @space.id == 1
    @users = @search.results  
    else
    @users = @search.results.select {|user| @space.actors.include?(user)}
    end
  end    
end
