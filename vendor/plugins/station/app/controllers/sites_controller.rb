class SitesController < ApplicationController

  # GET /site
  # GET /site.xml
  def show
    @site = current_site
  end

  # GET /site/new
  # GET /site/new.xml
  def new
    redirect_to edit_site_path
  end

  # GET /site/edit
  def edit
    @site = current_site
  end

  # POST /site
  # POST /site.xml
  def create
    update
  end

  # PUT /site
  # PUT /site.xml
  def update
    respond_to do |format|
      if current_site.update_attributes(params[:current_site])
        flash[:success] = t('site.updated')
        format.html { redirect_to site_path }
        format.xml  { head :ok }
      else
        @site = current_site
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site
  # DELETE /site.xml
  def destroy
    current_site.destroy if Site.count > 0

    respond_to do |format|
      format.html { redirect_to root_path  }
      format.xml  { head :ok }
    end
  end
end
