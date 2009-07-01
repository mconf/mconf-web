class FrontpageController < ApplicationController
  layout "layouts/home"
  

  def index
    #popular_spaces = The spaces with more users
    @popular_spaces = Space.find(:all, :conditions => {:public => true}).sort_by{|s| s.users.size}.reverse.first(3)
    
    #recent_spaces = The last spaces created 
    @recent_spaces = Space.find(:all, :conditions => {:public => true},:order => "created_at Desc").first(3)
    
    #relevant_users = The relevant users are the users which have more posts
    @relevant_users = User.find(:all).sort_by{|user| user.posts.size}.reverse.first(4)
    
    #recent_posts = The latest updated threads in public spaces
    @recent_posts = Post.find(:all, :conditions => {:parent_id => nil}, :order => "created_at Desc").select{|p| !p.space.disabled? && p.space.public == true}.first(2)
    
    #recent_events = The upcoming events in public spaces
    @recent_events = Event.find(:all, :order => "start_date Desc").select{|p| !p.space.disabled? && p.space.public? && p.start_date.future?}.first(2)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spaces }
      format.atom
    end
  end
  
  def about
    @global = Space.find_by_name("GLOBAL")
    @latest_global_posts = Post.last_news(@global)
    render :layout=>false
  end
end