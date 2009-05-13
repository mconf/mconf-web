class SearchController < ApplicationController
  before_filter :space
  
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
    
    if (params[:time1] && params[:time2]) or (params[:start_date] && params[:end_date])
      if (params[:time1] && params[:time2])
      #@query1 = params[:time1]
      #@query2 = params[:time2]
      date1= Date.civil(params[:time1][:year].to_i, params[:time1][:month].to_i, params[:time1][:day].to_i)
      date2= Date.civil(params[:time2][:year].to_i, params[:time2][:month].to_i, params[:time2][:day].to_i)
      #date1 = Date.parse(@query1.to_s)
      date1ok =  date1.strftime("%Y%m%d")
      #date2 = Date.parse(@query2.to_s)
      date2ok =  date2.strftime("%Y%m%d")
      @filters = {'start_date' => date1.to_s..date2.to_s,'end_date' => date1.to_s..date2.to_s}
      elsif params[:start_date] && params[:end_date]
        date1 = params[:start_date].to_date
        date2 = params[:end_date].to_date
        date1ok =  date1.strftime("%Y%m%d")
        date2ok =  date2.strftime("%Y%m%d")
        @filters = {'start_date' => date1.to_s..date2.to_s,'end_date' => date1.to_s..date2.to_s}
      end  
      if date1ok > date2ok
        flash[:notice] = 'The first date cannot be lower than the second one'
        render :template => "events/search"
      else
      
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
    @search = Ultrasphinx::Search.new(:query => @query,  :per_page => 1000000, :class_names => 'Post')
    @search.run
=begin
    @parents = []
    @search.results.select{|post| post.space == @space}.map{|post| 
      if post.parent_id !=nil
         @parents << post.parent 
     else
         @parents << post
     end
       }
    @parents.uniq!
=end
    posts = @search.results.select{|post|
            post.space == @space
          }.sort{
            |x,y| ((y.parent_id != nil) ? y.parent.updated_at : y.updated_at) <=> ((x.parent_id != nil) ? x.parent.updated_at : x.updated_at)
          }
    @posts = posts.paginate(:page => params[:page],:per_page => 5)
    @number_of_posts = posts.size
                    
end
  
  def search_users (params)
    @query = params[:query]
    
    @search = Ultrasphinx::Search.new(:query => @query, :class_names => 'User')
    @search.run
    @users = @search.results.select {|user| @space.actors.include?(user)}
  end
end

