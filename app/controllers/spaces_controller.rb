class SpacesController < ApplicationController
  before_filter :authentication_required, :except => [ :index, :register, :show ]

  authorization_filter :space, :read, :only => [:show]
  authorization_filter :space, :update, :only => [:edit, :update]
  authorization_filter :space, :delete, :only => [:destroy]
  
  set_params_from_atom :space, :only => [ :create, :update ]

  before_filter :public_read_ñapa, :only => [ :create, :update ]


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
    @posts = []
    if @space.id == 1
      
      @posts = get_public_entries.select {|e| e.parent_id == nil && e.content_type == 'Article'}.first(5)
   else
     @space_articles = (Entry.find_all_by_content_type_and_container_id('Article', @space.id, :order => "updated_at DESC")).select {|e| e.parent_id == nil}
     @posts = @space_articles.first(5)
     # @space_articles = @space.container_entries.find_all_by_content_type('Article', :order => "updated_at DESC")
     # @posts = get_last_updated(@space_articles).first(5)
    end
    
    next_events
    #@space_thumbnail = Logotype.find(:first, :conditions => {:parent_id => @space.logotype, :thumbnail => 'space'})
    session[:current_tab] = "Home"        
    session[:current_sub_tab] = ""
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @space }
      format.atom
    end
  end
  
  # GET /spaces/new
  def new
    @space_new = Space.new
    session[:current_tab] = "Manage" 

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
    #esto es para que el fckeditor no muestre la descripción del espacio en el que estás
    params[:space][:description] = params[:space_new][:description] if params[:space_new]

    
    @space = Space.new(params[:space])
    @logotype = Logotype.new(params[:logotype]) 
    @space.logotype = @logotype
    
    respond_to do |format|
      if @space.save
        flash[:notice] = 'Space was successfully created.'
        @space.stage_performances.create :agent => current_user, :role => Space.roles.find{ |r| r.name == 'Admin' }
        format.html { redirect_to(:action => "index", :controller => "spaces") }
        format.xml  { render :xml => @space, :status => :created, :location => @space }
        format.atom { 
          headers["Location"] = formatted_space_url(@space, :atom )
          render :action => 'show',
                 :status => :created
        }
      else
        format.html { @space_new = Space.new
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
    @space = Space.find_by_name(params[:id])
    

    #En primer lugar miro si se ha eliminado la foto del espacio y la borro de la base de datos
    if params[:delete_thumbnail] && params[:delete_thumbnail] == "true"
      @space.logotype = nil
    end

    if params[:logotype] && params[:logotype]!= {"uploaded_data"=>""}
          @logotype = Logotype.new(params[:logotype]) 
          if !@logotype.valid?
          flash[:error] = "The logotype is not valid"  
          render :action => "edit"   
          return
        end
          @space.logotype = @logotype
    end
    
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

  def get_space
    if params[:space_id]
      @container = @space = Space.find_by_name(params[:space_id])
    elsif params[:id]
      @container = @space = Space.find_by_name(params[:id])
    elsif session[:space_id]
      @container = @space = Space.find_by_name(session[:space_id])
    else
      @container = @space = Space.find_by_name("Public")
    end 
    @space = @container = Space.find_by_id(1) if @space == nil
    session[:space_id] = @space.name
    @space_thumbnail = Logotype.find(:first, :conditions => {:parent_id => @space.logotype, :thumbnail => 'space'})
  end
  
  def public_read_ñapa
    if params[:space][:public] == "1"
      params[:space][:_stage_performances] = [ 
        { :role_id => Role.find_by_name_and_stage_type("Invited", "Space").id,
          :agent_id => Anyone.current.id,
          :agent_type => Anyone.current.class.base_class.to_s
        },

      ]
    else 
      params[:space][:_stage_performances] = Array.new
    end
  end

  
end
