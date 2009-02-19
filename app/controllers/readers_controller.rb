class ReadersController < ApplicationController
  # GET /readers
  # GET /readers.xml
  def index
    @readers = Reader.find(:all, :conditions => {:space_id => @space.id})

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @readers }
    end
  end

  # GET /readers/1
  # GET /readers/1.xml
  def show
    @reader = Reader.find(params[:id], :conditions => {:space_id => @space.id})

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @reader }
    end
  end

  # GET /readers/new
  # GET /readers/new.xml
  def new
    @reader = Reader.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @reader }
    end
  end

  # GET /readers/1/edit
  def edit
    @reader = Reader.find(params[:id], :conditions => {:space_id => @space.id})
  end

  # POST /readers
  # POST /readers.xml
  def create
    @reader = Reader.new(params[:reader])

    respond_to do |format|
      if @reader.save
        flash[:notice] = 'Reader was successfully created.'
        format.html { redirect_to(space_reader_path(@space,@reader)) }
        format.xml  { render :xml => @reader, :status => :created, :location => @reader }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @reader.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /readers/1
  # PUT /readers/1.xml
  def update
    @reader = Reader.find(params[:id])

    respond_to do |format|
      if @reader.update_attributes(params[:reader])
        flash[:notice] = 'Reader was successfully updated.'
        format.html { redirect_to(space_reader_path(@space, @reader)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @reader.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /readers/1
  # DELETE /readers/1.xml
  def destroy
    @reader = Reader.find(params[:id])
    @reader.destroy

    respond_to do |format|
      format.html { redirect_to(space_readers_url(@space)) }
      format.xml  { head :ok }
    end
  end
end
