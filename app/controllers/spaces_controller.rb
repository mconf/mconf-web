class SpacesController < ApplicationController
  before_filter :authentication_required, :except=>[:index, :register,:show]
  #before_filter :is_public_space, :only=>[:show]
  before_filter :user_is_admin , :only=> [:new,:create,:destroy]
  #before_filter :space_member, :only=>[:show]

  
  #  before_filter :is_public_space, :only=>[:show]
#  before_filter :user_is_admin , :only=> [:new,:create,:destroy]
#  before_filter :space_member, :only=>[:show]

 before_filter :current_site
 authorization_filter :current_site, :create, :only => [:new, :create]
 authorization_filter :space, :read, :only => [:show]
 authorization_filter :space, :update, :only => [:edit, :update]
 authorization_filter :space, :delete, :only => [:destroy]

  before_filter :public_read_ñapa, :only => [ :create, :update ]

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

#metodos trasladados al controlador de usuarios  
  
=begin

  
  def add_user2
     session[:current_sub_tab] = "Add Users from App"
    if params[:users] && params[:user_role]
      if Role.find_by_name(params[:user_role])
        for user_id in params[:users][:id]
          #let`s check if the performance already exist
          perfor = Performance.find_by_container_id_and_agent_id(@space.id,user_id, :conditions=>["role_id = ?", Role.find_by_name(params[:user_role])])
          if perfor==nil
            #if it does not exist we create it
            @space.container_performances.create :agent => User.find(user_id), :role => Role.find_by_name(params[:user_role])
          end
        end
      else        
        flash[:notice] = 'Role ' + params[:user_role] + ' does not exist.'
      end
      
    end
  end
  
  def remove_user
    if params[:users] && params[:user_role]
      if Role.find_by_name(params[:user_role])
        for user_id in params[:users][:id]
          #let`s check if the performance exist
          perfor = Performance.find_by_container_id_and_agent_id(@space.id,params[:users][:id], :conditions=>["role_id = ?", Role.find_by_name(params[:user_role])])
          if perfor
            #if it exists we remove it
            @space.container_performances.delete perfor
          end
        end
      end     
    end
    respond_to do |format|
      format.html { redirect_to :action=>"add_user" }
      format.xml  { head :ok }
    end
  end
  
  def add_user  
    #parsear string de emails y hacer todo lo de abajo para cada email.
    session[:current_sub_tab] = "Add Users by email"
    if params[:invitation] && params[:user_role]
      
      if params[:invitation][:email]== ""
        flash[:notice] = "Please insert something in the box"      
        redirect_to  add_user_path
      else
        @parse_email = /^([a-zA-Z0-9_\-\.]+)@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.)|(([a-zA-Z0-9\-]+\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\]?)$/
        @em = params[:invitation][:email]      
        @emails =parse_emails(@em)             
        @role = Role.find_by_name(params[:user_role])
        params[:invitation][:space_id]= params[:space_id]
        params[:invitation][:user_id]= current_user.id
        params[:invitation][:role_id]= @role.id
        @sp = params[:space_id]
        @space_required = Space.find(@sp)
        @users_invited= []
        @users_added = []
        @users_not_added = []
        @emails_invalid = []
        for email in @emails
          
          @p = /\S+@\S+\.\S+/
          @mail = @p.match(email).to_s
          
          
          @mail = @mail.gsub(/>/,' ')
          @mail = @mail.gsub(/</,' ')
          @mail = @p.match(@mail).to_s
          
          if  @parse_email.match(@mail)!= nil
            params[:invitation][:email]= @mail
            @user = User.find_by_email(@mail)
            if @user
              @perfor = Performance.find_by_container_id_and_agent_id(params[:space_id],@user.id)
            end
            if @user == nil 
              #falta notificar por mail
              @inv = Invitation.new(params[:invitation])        
              @inv.save! 
              @users_invited << @inv.email
            elsif  @perfor == nil
              @space_required.container_performances.create :agent => @user, :role => Role.find_by_name(params[:user_role])
              #esta en el sir pero no en el espacio, no añado a la tabla le añado al espacio y le notifico pro mail
              @users_added << @user.email
              #falta notificar por mail
            else
              #el usuraio ya esta en el esapcio
              @users_not_added << @user.email
            end
          else
            @emails_invalid << email          
          end
          
        end
        respond_to do |format|
          flash[:notice] = "Users were succesfully invited to the space #{@space_required.name}. An email has been sended to them"
          
          format.html { render :template => '/spaces/invitations_results' }
          format.xml  { head :ok }        
        end
        
      end 
    end
  end
=end

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
        { :role_id => Role.without_stage_type.find_by_name("Reader").id,
          :agent_id => Anyone.current.id,
          :agent_type => Anyone.current.class.base_class.to_s
        },
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
