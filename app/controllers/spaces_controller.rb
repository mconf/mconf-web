class SpacesController < ApplicationController
  include CMS::Controller::Base
  include CMS::Controller::Authorization
  before_filter :authentication_required, :except=>[:register,:show]
   before_filter :get_space , :only =>[:edit, :add_user,:add_user2,:update, :show]
   before_filter :is_public_space, :only=>[:show]
  before_filter :get_cloud
  before_filter  :user_is_admin , :only=> [:index, :new,:create,:destroy]
 
  before_filter  :can__edit__space__filter, :only=>[:edit,:update]
  before_filter  :can__manage_groups__space__filter, :only=>[:add_user, :add_user2]
  before_filter :remember_tab_and_space
  before_filter :not_public_space, :only=>[:add_user, :add_user2]
  before_filter :space_member, :only=>[:show]
  
  def index
    @spaces = Space.find(:all, :conditions=>["id != 1"] )
    session[:current_tab] = "Manage" 
    session[:current_sub_tab] = "Spaces"
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spaces }
    end
  end
  
  # GET /spaces/1
  def show   
   # debugger
    if @space.id == 1
      get_public_posts
    end
    next_events
    session[:current_tab] = "Home"        
    session[:current_sub_tab] = ""
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
    session[:current_sub_tab] = "Edit Space"
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
      
      redirect_to :action => "show" , :id => @space.id
      
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
  
  
  def add_user2
     session[:current_sub_tab] = "Add Users from App"
    if params[:users] && params[:user_role]
      if CMS::Role.find_by_name(params[:user_role])
        for user_id in params[:users][:id]
          #let`s check if the performance already exist
          perfor = CMS::Performance.find_by_container_id_and_agent_id(@space.id,user_id, :conditions=>["role_id = ?", CMS::Role.find_by_name(params[:user_role])])
          if perfor==nil
            #if it does not exist we create it
            @space.container_performances.create :agent => User.find(user_id), :role => CMS::Role.find_by_name(params[:user_role])
          end
        end
      end
      
    end
  end
  
  def remove_user
    if params[:users] && params[:user_role]
      if CMS::Role.find_by_name(params[:user_role])
        for user_id in params[:users][:id]
          #let`s check if the performance exist
          perfor = CMS::Performance.find_by_container_id_and_agent_id(@space.id,params[:users][:id], :conditions=>["role_id = ?", CMS::Role.find_by_name(params[:user_role])])
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
        @role = CMS::Role.find_by_name(params[:user_role])
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
              @perfor = CMS::Performance.find_by_container_id_and_agent_id(params[:space_id],@user.id)
            end
            if @user == nil 
              #falta notificar por mail
              @inv = Invitation.new(params[:invitation])        
              @inv.save! 
              @users_invited << @inv.email
            elsif  @perfor == nil
              @space_required.container_performances.create :agent => @user, :role => CMS::Role.find_by_name(params[:user_role])
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
  
  def register
    render :template =>'users/new'
    
  end
  private
  #method to parse the request for update from the server that contains
  #<div id=d1>ebarra</div><div id=d2>user2</div>...
  #returns an array with the user logins
  def parse_emails(emails)
    
    return [] if emails.blank?
    emails = Array(emails).first
    emails = emails.respond_to?(:flatten) ? emails.flatten : emails.split(Invitation::DELIMITER)
    emails.map { |email| email.strip.squeeze(" ") }.flatten.compact.map(&:downcase).uniq
    
  end
  
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
