class SourcesController < ApplicationController
  # GET /sources
  # GET /sources.xml
  def index
    @sources = (path_container && path_container.sources || Source).all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @sources }
    end
  end

  # GET /sources/1
  # GET /sources/1.xml
  def show
    @source = Source.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @source }
    end
  end

  def import
    @source = Source.find(params[:id])
    @source.import

    redirect_to polymorphic_path([ @source.container, @source.target.constantize.new ])
  end

  # GET /sources/new
  # GET /sources/new.xml
  def new
    @source = Source.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @source }
    end
  end

  # GET /sources/1/edit
  def edit
    @source = Source.find(params[:id])
  end

  # POST /sources
  # POST /sources.xml
  def create
    @source = Source.new(params[:source])
    @source.container = path_container

    respond_to do |format|
      if @source.save
        flash[:notice] = 'Source was successfully created.'
        format.html { redirect_to( @source) }
        format.xml  { render :xml => @source, :status => :created, :location => @source }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /sources/1
  # PUT /sources/1.xml
  def update
    @source = Source.find(params[:id])

    respond_to do |format|
      if @source.update_attributes(params[:source])
        flash[:notice] = 'Source was successfully updated.'
        format.html { redirect_to(@source) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @source.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /sources/1
  # DELETE /sources/1.xml
  def destroy
    @source = Source.find(params[:id])
    @source.destroy

    respond_to do |format|
      format.html { redirect_to([ @source.container, Source.new ]) }
      format.xml  { head :ok }
    end
  end
end
