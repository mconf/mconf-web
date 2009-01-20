class SearchController < ApplicationController
  
  
  def all
    
    @events = search_events(params)
    @users = search_users(params)
    @entries = search_articles(params)
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
  
  
  def articles
    search_articles(params)
    
    respond_to do |format|   
      format.html
      format.js 
    end
  end
  
  
  def advanced_search_events
    
  end
  
  def tag
    
    @tag = Tag.find_by_name(params[:tag])
    @users = @tag.taggings.all(:conditions => [ "taggable_type = ?", "User" ]).map{ |t| 
      User.find(t.taggable_id) 
    }

    @events = @tag.taggings.all(:conditions => [ "taggable_type = ?", "Event" ]).map{ |t| 
      Event.find(t.taggable_id) 
    }

    @entries = @tag.taggings.all(:conditions => [ "taggable_type = ?", "Article" ]).map{ |t| 
      Entry.find_by_content_id_and_content_type(t.taggable_id, 'Article')
    }
    @articles = @entries.map{|e| e.content if e != nil}.select{|e| e if e != nil}
    @query = params[:tag]
    respond_to do |format|        
      format.html     
    end
  end
  
  def users
    search_users(params)
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
      @events = @search.results.select{|event| event.entry.container == @space}
      
      #@even = Entry.find_all_by_container_id_and_content_type(@space.id, "Event")
      #@total, @results = Event.full_text_search(@query,  :page => (params[:page]||1))          
      #@pages = pages_for(@total)
      #@partials = []
      #@events = []  
      #if @results != nil
       # @results.collect { |result|
       #   event = Entry.find_by_content_type_and_content_id("Event", result.id)
       #   if @even.include?(event)
       #     @partials << event
       #   end
       # }
      #end
      #if @partials != nil
      #  @partials.collect { |a|
      #    even = Event.find(a.content_id)
      #    @events << even
      #  }      
      #end
    end
    if params[:title]
      @query = params[:title]
      @search = Ultrasphinx::Search.new(:class_names => 'Event', :filters => {'name' => @query})
      @search.run
      @events = @search.results.select{|event| event.entry && event.entry.container == @space}
      #@total, @events = Event.title_search(@query,  :page => (params[:page]||1))          
      #@pages = pages_for(@total)
    end
    if params[:description]
      @query = params[:description]
      @search = Ultrasphinx::Search.new(:class_names => 'Event', :filters => {'description' => @query})
      @search.run
      @events = @search.results.select{|event| event.entry && event.entry.container == @space}
      #@total, @events = Event.description_search(@query,  :page => (params[:page]||1))          
      #@pages = pages_for(@total)
    end
    if params[:time1] && params[:time2]
      @query1 = params[:time1]
      @query2 = params[:time2]
      #cambiamos el formato de las fechas,, creando un objeto de tipo date y transformandolo
      #a formato Ymd => 20081124
      #query_start_date_int = Chronic.parse(@query1).to_i
      #query_end_date_int = Chronic.parse(@query2).to_i
      date1 = Date.parse(@query1)
      date1ok =  date1.strftime("%Y%m%d")
      date2 = Date.parse(@query2)
      date2ok =  date2.strftime("%Y%m%d")
      if date1ok > date2ok
        #if query_start_date_int > query_end_date_int
        flash[:notice] = 'The first date cannot be lower than the second one'
        render :template => "events/search"
      else
      #@filters = {'event_datetime_start_date' => query_start_date_int..query_end_date_int,'event_datetime_end_date' => query_start_date_int..query_end_date_int}
      @filters = {'event_datetime_start_date' => @query1..@query2,'event_datetime_end_date' => @query1..@query2}
      @search = Ultrasphinx::Search.new(:class_names => 'Event',:filters => @filters)
      @search.run
      @events= @search.results
      @query = ""
        #@total, @events, @query = Event.date_search(@query1,@query2,  :page => (params[:page]||1))          
        #@pages = pages_for(@total)
      end
    end
    @events
  end
  
  def search_entries (params)
    
  end
  
  def search_articles (params)
    
    @query = params[:query] 
    @search = Ultrasphinx::Search.new(:query => @query, :class_names => 'Article')
    @search.run
   # @search.results
    @articles = @search.results.select{|article| article.entry!=nil && article.entry.parent_id == nil}.sort_by{|e| e.updated_at}.reverse
    #@entries = @articles_entries.map{|article| article.entry}.sort_by{|e| e.updated_at}.reverse
    
   # @results = Article.find_by_contents(@query)
   # @pos = @space.container_entries    
   # @entries = []   
   # @results.collect { |result|
   #   entry = Entry.find_by_content_type_and_content_id("Article", result.id)
   #   if @pos.include?(entry)
   #     @entries << entry
    #  end
    #}
    #@entries
  end
  
  def search_users (params)
    @query = params[:query]
    
    @search = Ultrasphinx::Search.new(:query => @query, :class_names => 'User')
    @search.run
    #@search.results
    if @space.id == 1
    @users = @search.results  
    else
    @users = @search.results.select {|user| @space.actors.include?(user)}
    end
   # @use = User.find_by_contents(@query)
   # @users = []
   # i = 0
    
   # @agen = @space.actors
    
   # @use.collect { |user|
   #   if @agen.include?(user)
   #     @users << user
    #  end
   # }
   # @users
  end
  
  
=begin
 #### Este método era el antiguo search_all que estaba en el controlador HomeController
    def search_all (params)
    #search in events in this space
    @query = params[:query]
    @even = Entry.find_all_by_container_id_and_content_type(@container.id, "Event")
    @total, @results = Event.full_text_search(@query,:lazy => [:name, :description, :tag_list, :start_dates],  :page => (params[:page]||1))          
    @pages = pages_for(@total)
    @partials = []
    @events = []  
     if @results != nil
    @results.collect { |result|
      event = Entry.find_by_content_type_and_content_id("Event", result.id)
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
      if @agen.include?(user)
          @users << user
      end
     }

    #search entries
    
     @results = Article.find_by_contents(@query)
    @pos = @container.container_entries    
    @entries = []   
    @results.collect { |result|
      entry = Entry.find_by_content_type_and_content_id("Article", result.id)
      if @pos.include?(entry)
        @entries << entry
      end
    }
    
  end
=end
  
end
