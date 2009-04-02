class SpacesController < ApplicationController
  before_filter :authentication_required, :except => [ :index, :register, :show, :new, :create ]

  #authorization_filter :space, :read, :only => [:show]
  #authorization_filter :space, :update, :only => [:edit, :update]
  #authorization_filter :space, :delete, :only => [:destroy]
  before_filter :space
  set_params_from_atom :space, :only => [ :create, :update ]

  # GET /spaces
  # GET /spaces.xml
  # GET /spaces.atom
  def index
    @spaces = Space.find(:all, :conditions=>["id != 1"] )    
    if @space
       session[:current_tab] = "Spaces" 
    end
    if params[:manage]
      session[:current_tab] = "Manage" 
      session[:current_sub_tab] = "Spaces"
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spaces }
      format.atom
    end
  end
  
  # GET /spaces/1
  # GET /spaces/1.xml
  # GET /spaces/1.atom
  def show  
    @posts = @space.posts
    @lastest_posts=@posts.find(:all, :conditions => {"parent_id" => nil}, :order => "updated_at DESC").first(5)
    @lastest_users=@space.actors.sort {|x,y| y.created_at <=> x.created_at }.first(5)
    @incoming_events=@space.events.find(:all, :order => "start_date DESC").select{|e| e.start_date.future?}.first(5)
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @space }
      format.atom
    end
  end
  
  # GET /spaces/new
  def new
    
  end
  
  # GET /spaces/1/edit
  def edit
    session[:current_sub_tab] = "Edit Space"
    #@space_thumbnail = Logotype.find(:first, :conditions => {:parent_id => @space.logotype, :thumbnail => 'space'})
  end
  
  
  # POST /spaces
  # POST /spaces.xml 
  # POST /spaces.atom
  # {"space"=>{"name"=>"test space", "public"=>"1", "description"=>"<p>this is the description of the space</p>"}
  def create
    unless logged_in?
      if params[:register]
        cookies.delete :auth_token
        @user = User.new(params[:user])
        unless @user.save_with_captcha
          message = ""
          @user.errors.full_messages.each {|msg| message += msg + "  <br/>"}
          flash[:error] = message
          render :action => :new
          return
        end
      end
        
      self.current_agent = User.authenticate_with_login_and_password(params[:user][:email], params[:user][:password])
      unless logged_in?
          flash[:error] = "Invalid credentials"
          render :action => :new
          return
      end
    end
      
    @space = Space.new(params[:space])
    #@logotype = Logotype.new(params[:logotype]) 
    #@space.logotype = @logotype
    
    respond_to do |format|
      if @space.save
        flash[:success] = 'Space was successfully created.'
        #@space.stage_performances.create :agent => current_user, :role => Space.roles.find{ |r| r.name == 'Admin' }
        format.html { redirect_to :action => "show", :id => @space  }
        format.xml  { render :xml => @space, :status => :created, :location => @space }
        format.atom { 
          headers["Location"] = formatted_space_url(@space, :atom )
          render :action => 'show',
                 :status => :created
        }
      else
        format.html {
          message = ""
          @space.errors.full_messages.each {|msg| message += msg + "  <br/>"}
          flash[:error] = message
          render :action => :new }
        format.xml  { render :xml => @space.errors, :status => :unprocessable_entity }
        format.atom { render :xml => @space.errors.to_xml, :status => :bad_request }
      end
    end
  end
  
  
  # PUT /spaces/1
  # PUT /spaces/1.xml
  # PUT /spaces/1.atom
  def update
    if @space.update_attributes(params[:space]) 
      respond_to do |format|
        format.html { 
          flash[:notice] = 'Space was successfully updated.'
          @spaces = Space.find(:all )
          redirect_to space_path(@space)
        }
        format.atom { head :ok }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @space.errors, :status => :unprocessable_entity }
        format.atom { render :xml => @space.errors.to_xml, :status => :not_acceptable }
      end      
    end
  end
  
  
  # DELETE /spaces/1
  # DELETE /spaces/1.xml
  # DELETE /spaces/1.atom
  def destroy
    @space_destroy = Space.find_by_name(params[:id])
    @space_destroy.destroy
    flash[:notice] = 'Space was successfully removed.'
    respond_to do |format|
      format.html { redirect_to(spaces_url) }
      format.xml  { head :ok }
      format.atom { head :ok }
    end
  end

 #Este metodo no parece que tenga ningun sentido
  def register
    render :template =>'users/new'
    
  end

  private
  
  
  
  #method to parse the request for update from the server that contains
  #<div id=d1>ebarra</div><div id=d2>user2</div>...
  #returns an array with the user logins

  def space
    @space = Space.find_with_param(params[:id])
  end
end
