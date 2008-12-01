
class RolesController < ApplicationController
  before_filter  :user_is_admin , :only=> [:index,:show, :new,:create, :edit,:update,:destroy]
  
  before_filter :authentication_required
  before_filter :remember_tab_and_space
  before_filter :space_member, :only=>[:group_details,:show_groups,:groups_details]

  authorization_filter :space, [ :manage, :Role ]
  
  def index
   
    session[:current_tab] = "Manage" 
    @role = Role.find_all_by_type(nil)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @role }
    end
  end
  
  
  def show
    @role = Role.find(params[:id] )
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end
  
  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = Role.new    
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end
  
  # GET /roles/1/edit
  def edit
    @role = Role.find(params[:id])
  end
  
  
  # POST /roles
  # POST /roles.xml
  def create    
    @role = Role.new(params[:cms_role])  
    respond_to do |format|
      if @role.save
        flash[:notice] = 'Role was successfully created.'
        format.html { redirect_to(:action => "index", :controller => "roles") }
        format.xml  { render :xml => @role, :status => :created, :location => @role }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  
  # PUT /roles/1
  # PUT /roles/1.xml
  def update  
    @role = Role.find(params[:id])    
    respond_to do |format|
      if @role.update_attributes(params[:cms_role])
        flash[:notice] = 'Role was successfully updated.'
        format.html { redirect_to(:action => "index", :controller => "roles") }
        format.xml  { head :ok }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @role.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /roles/1
  # DELETE /roles/1.xml
  def destroy
    @role = Role.find(params[:id])
     @performances = Performance.find_all_by_role_id(@role.id)
     for performance in @performances
      performance.destroy
    end
    @role.destroy    
    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
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
