class SpacesController < ApplicationController
  include CMS::Controller::Base
  include CMS::Controller::Authorization
  before_filter :authentication_required
  before_filter  :user_is_admin , :only=> [:index, :new,:create,:destroy]
  before_filter :get_space , :only =>[:edit, :add_user,:update, :show]
  before_filter  :can__edit__space__filter, :only=>[:edit,:update]
  before_filter  :can__add_users__space__filter, :only=>[:add_user]
  before_filter :remember_tab_and_space
  
  def index
    @spaces = Space.find(:all, :conditions=>["id != 1"] )
    session[:current_tab] = "Manage" 
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spaces }
    end
  end
  
  # GET /spaces/1
  def show

   @cloud = Tag.cloud
   next_events

    session[:current_tab] = "Home"    

  end
  
  # GET /spaces/new
  # GET /spaces/new.xml
  def new
    @space_new = Space.new
    session[:current_tab] = "Manage" 
    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @space_new }
    end
  end
  
  # GET /spaces/1/edit
  def edit
    
  end
  
  
  # POST /spaces
  # POST /spaces.xml
  def create    
    @space = Space.new(params[:space])
    
    respond_to do |format|
      if @space.save
        flash[:notice] = 'Space was successfully created.'
        format.html { redirect_to(:action => "index", :controller => "spaces") }
        format.xml  { render :xml => @space, :status => :created, :location => @space }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @space.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  
  # PUT /spaces/1
  # PUT /spaces/1.xml
  def update
    @space = Space.find(params[:id])
    
    if @space.update_attributes(params[:space])
      #fist of all we delete all the old performances, but not the groups
      @space.delete_performances
      for role in CMS::Role.find_all_by_type(nil)
        if params[role.name]
          for login in parse_divs(params[role.name].to_s)
            @space.container_performances.create :agent => User.find_by_login(login), :role => role
          end
        end
      end
      @space.save!
      flash[:notice] = 'Space was successfully updated.'
      @spaces = Space.find(:all )
      
      render :action => "index" 
      
    else
      respond_to do |format|
        format.html { render :action => "index" }
        format.xml  { render :xml => @space.errors, :status => :unprocessable_entity }
      end      
    end
  end
  
  
  # DELETE /spaces/1
  # DELETE //1.xml
  def destroy
    @space = Space.find(params[:id])
    @space.destroy
    flash[:notice] = 'Space was successfully removed.'
    respond_to do |format|
      format.html { redirect_to(spaces_url) }
      format.xml  { head :ok }
    end
  end
  
  
  def add_user
    
  end
  
  def register_user
    
  end
  
  
  
  private
  #method to parse the request for update from the server that contains
  #<div id=d1>ebarra</div><div id=d2>user2</div>...
  #returns an array with the user logins
  def parse_divs(divs)
    #REXML da un error de que no puede añadir al root element, voy a crear un root element en divs
    str = "<temp>"+divs+"</temp>"
    #remove the characters "\n\r\t" that javascript introduces
    str = str.tr("\r","").tr("\n","").tr("\t","")
    doc = REXML::Document.new(str)
    array = Array.new
    REXML::XPath.each(doc, "//div") { |p| 
      #if the div has the style attribute with the none param is because it has been moved to the bin
      if p.attributes["style"]
        if p.attributes["style"].include? "none"
          next
        end
      end
      array << p.text
    }
    return array
  end
  
  
end
