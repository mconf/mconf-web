class LogotypesController < ApplicationController
  # GET /logotypes
  # GET /logotypes.xml
  def index
    @logotypes = Logotype.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @logotypes }
    end
  end

  # GET /logotypes/1
  # GET /logotypes/1.xml
  def show
    if params[:thumbnail]
      @image = Logotype.find(params[:thumbnail])
    end
    #if params[:usuario]
    #  @usuario = User.find(params[:usuario])
    #  if @usuario.profile.logotype
    #    @image = @image = Logotype.find(:first, :conditions => {:parent_id => @usuario.profile.logotype, :thumbnail => ''})
    #  end
    #elsif params[:image_space]
    #  @this_space = Space.find_by_name(params[:image_space])
    #  if @this_space.logotype
    #     @image = Logotype.find(:first, :conditions => {:parent_id => @this_space.logotype, :thumbnail => 'space'})
    #  end
    #else
      #si hubiera algún otro tipo de modelo con logo iría aquí en otro elsif
    #end
    respond_to do |format|
      format.html {
      if @image
      send_data @image.current_data, :filename => @image.filename,
                                             :type => @image.content_type,
                                             :disposition => 'inline'
      end
      } # show.html.erb
      format.xml  { render :xml => @logotype }
    end
  end

  # GET /logotypes/new
  # GET /logotypes/new.xml
  def new
    @logotype = Logotype.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @logotype }
    end
  end

  # GET /logotypes/1/edit
  def edit
    @logotype = Logotype.find(params[:id])
  end

  # POST /logotypes
  # POST /logotypes.xml
  def create
    @logotype = Logotype.new(params[:logotype])

    respond_to do |format|
      if @logotype.save
        flash[:notice] = 'Logotype was successfully created.'
        format.html { redirect_to(@logotype) }
        format.xml  { render :xml => @logotype, :status => :created, :location => @logotype }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @logotype.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /logotypes/1
  # PUT /logotypes/1.xml
  def update
    @logotype = Logotype.find(params[:id])

    respond_to do |format|
      if @logotype.update_attributes(params[:logotype])
        flash[:notice] = 'Logotype was successfully updated.'
        format.html { redirect_to(@logotype) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @logotype.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /logotypes/1
  # DELETE /logotypes/1.xml
  def destroy
    @logotype = Logotype.find(params[:id])
    @logotype.destroy

    respond_to do |format|
      format.html { redirect_to(logotypes_url) }
      format.xml  { head :ok }
    end
  end
end
