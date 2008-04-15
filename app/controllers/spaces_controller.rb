class SpacesController < ApplicationController
  
  def index
    @spaces = Space.find(:all )
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @spaces }
    end
  end
  
  
  # GET /spaces/new
  # GET /spaces/new.xml
  def new
    @space = Space.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @space }
    end
  end

  # GET /spaces/1/edit
  def edit
    @space = Space.find(params[:id])
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
    respond_to do |format|
      if @space.update_attributes(params[:space])
        if params[:users] && params[:users][:id]
          debugger
        end
        flash[:notice] = 'Space was successfully updated.'
        @spaces = Space.find(:all )
        format.html { render :action => "index" }
        format.xml  { head :ok }
      else
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

    respond_to do |format|
      format.html { redirect_to(spaces_url) }
      format.xml  { head :ok }
    end
  end
  
  
  def add_user
    @space = Space.find(params[:id])   
  end
  
  
  
  
end