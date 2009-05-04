class SpacesController < ApplicationController
  before_filter :space

  authorization_filter :read,   :space, :only => [:show]
  authorization_filter :update, :space, :only => [:edit, :update]
  authorization_filter :delete, :space, :only => [:destroy]
  authorization_filter [ :create, :performance ], :space, :only => [:join]

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
    @news_position = (params[:news_position] ? params[:news_position].to_i : 0) 
    @news = @space.news.find(:all, :order => "updated_at DESC")
    @news_to_show = @news[@news_position]
    @posts = @space.posts
    @lastest_posts=@posts.find(:all, :conditions => {"parent_id" => nil}, :order => "updated_at DESC").first(5)
    @lastest_users=@space.actors.sort {|x,y| y.created_at <=> x.created_at }.first(5)
    @incoming_events=@space.events.find(:all, :order => "start_date DESC").select{|e| e.start_date.future?}.first(5)
    respond_to do |format|
      format.js {render :partial=>"last_news"}
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
    #@users = @space.actors.sort {|x,y| x.name <=> y.name }
    @performances = space.stage_performances.sort {|x,y| x.agent.name <=> y.agent.name }
    @roles = Role.find(:all)
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
    
    respond_to do |format|
      if @space.save
        flash[:success] = 'Space was successfully created.'
        @space.stage_performances.create :agent => current_user, :role => Space.roles.find{ |r| r.name == 'Admin' }
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
          flash[:success] = 'Space was successfully updated.'
          redirect_to request.referer
        }
        format.atom { head :ok }
        format.js{
          if params[:space][:name]
            @result = "window.location=\"#{edit_space_path(@space)}\";"
          end
          if params[:space][:description]
            @result=params[:space][:description]
          end
        }
      end
    else
      respond_to do |format|
        format.html { render :action => "edit" }
        format.xml  { render :xml => @space.errors, :status => :unprocessable_entity }
        format.atom { render :xml => @space.errors.to_xml, :status => :not_acceptable }
        format.js{}
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

  def join
    unless authenticated?
      return unless params[:user]

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
        return
      end
    end

    if space.users.include?(current_agent)
      flash[:notice] = "You are already in the space"
      redirect_to space
      return
    end

    if space.public?
      space.stage_performances.create! :agent => current_agent,
                                       :role => Space.roles.find{ |r| r.name == "User" }
    else
      space.join_requests.create! :candidate => current_user
      flash[:notice] = t('join_request.created')
    end
    redirect_to space
  end
  
   
  def change_space
    respond_to do |format|
      format.html { redirect_to(params[:space]) }
    end
  end
  
  private
  
  
  
  #method to parse the request for update from the server that contains
  #<div id=d1>ebarra</div><div id=d2>user2</div>...
  #returns an array with the user logins

  def space
    @space = Space.find_with_param(params[:id])
  end
end
