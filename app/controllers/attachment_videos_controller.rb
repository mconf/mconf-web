class AttachmentVideosController < ApplicationController
  # GET /attachment_videos
  # GET /attachment_videos.xml
  def index
    @attachment_videos = AttachmentVideo.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @attachment_videos }
    end
  end

  # GET /attachment_videos/1
  # GET /attachment_videos/1.xml
  def show
    @attachment_video = AttachmentVideo.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @attachment_video }
    end
  end

  # GET /attachment_videos/new
  # GET /attachment_videos/new.xml
  def new
    @attachment_video = AttachmentVideo.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @attachment_video }
    end
  end

  # GET /attachment_videos/1/edit
  def edit
    @attachment_video = AttachmentVideo.find(params[:id])
  end

  # POST /attachment_videos
  # POST /attachment_videos.xml
  def create
    @attachment_video = AttachmentVideo.new(params[:attachment_video])

    respond_to do |format|
      if @attachment_video.save
        flash[:notice] = 'AttachmentVideo was successfully created.'
        format.html { redirect_to(@attachment_video) }
        format.xml  { render :xml => @attachment_video, :status => :created, :location => @attachment_video }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @attachment_video.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /attachment_videos/1
  # PUT /attachment_videos/1.xml
  def update
    @attachment_video = AttachmentVideo.find(params[:id])

    respond_to do |format|
      if @attachment_video.update_attributes(params[:attachment_video])
        flash[:notice] = 'AttachmentVideo was successfully updated.'
        format.html { redirect_to(@attachment_video) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @attachment_video.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /attachment_videos/1
  # DELETE /attachment_videos/1.xml
  def destroy
    @attachment_video = AttachmentVideo.find(params[:id])
    @attachment_video.destroy

    respond_to do |format|
      format.html { redirect_to(attachment_videos_url) }
      format.xml  { head :ok }
    end
  end
end
