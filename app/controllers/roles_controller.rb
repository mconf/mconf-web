class RolesController < ApplicationController
  before_filter :authentication_required
  def index
    @role = CMS::Role.find(:all )
    

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @role }
    end
  end
  
  
  def show
    @role = CMS::Role.find(params[:id] )
  
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/new
  # GET /roles/new.xml
  def new
    @role = CMS::Role.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @role }
    end
  end

  # GET /roles/1/edit
  def edit
    @role = CMS::Role.find(params[:id])
  end


  # POST /roles
  # POST /roles.xml
  def create
    
    @role = CMS::Role.new(params[:cms_role])

 
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
   
    @role = CMS::Role.find(params[:id])

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
    @role = CMS::Role.find(params[:id])
    @role.destroy

    respond_to do |format|
      format.html { redirect_to(roles_url) }
      format.xml  { head :ok }
    end
  end

end
