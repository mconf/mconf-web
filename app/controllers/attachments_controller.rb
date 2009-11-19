class AttachmentsController < ApplicationController
  include ActionController::StationResources
  
  # Always needs a space
  before_filter :space!
  
  authorization_filter :create, :attachment, :only => [ :new, :create ]
  authorization_filter :read,   :attachment, :only => [ :index, :show ]
  authorization_filter :update, :attachment, :only => [ :edit, :update ]
  authorization_filter :delete, :attachment, :only => [ :delete ]
  
  def index
    attachments
  end
  
  def edit_tags
    @attachment = Attachment.find(params[:id])
  end

  private

  def attachments
    @tags = params[:tags].present? ? params[:tags].split(",").map{|t| Tag.in_container(@space).find(t.to_i)} : Array.new
    
    @attachments = Attachment.roots.in_container(@space).sorted(params[:order],params[:direction])
    
    #ask tapi to do it better
    @tags.each do |t|
      @attachments = @attachments.select{|a| a.tags.include?(t)}
    end
    
    @attachments.sort!{|x,y| x.author.name <=> y.author.name } if params[:order] == 'author' && params[:direction] == 'desc'
    @attachments.sort!{|x,y| y.author.name <=> x.author.name } if params[:order] == 'author' && params[:direction] == 'asc'
    @attachments.sort!{|x,y| x.content_type.split("/").last <=> y.content_type.split("/").last } if params[:order] == 'type' && params[:direction] == 'desc'
    @attachments.sort!{|x,y| y.content_type.split("/").last <=> x.content_type.split("/").last } if params[:order] == 'type' && params[:direction] == 'asc'
  end

  # Redirect to spaces/:permalink/attachments if new attachment is created
  def after_create_with_success
    redirect_to [ space, Attachment.new ]
  end
  def after_update_with_success
    redirect_to [ space, Attachment.new ]
  end

  def after_create_with_errors
    flash[:error] =  @attachment.errors.to_xml
    attachments
    render :action => :index
  end
 
  def after_update_with_errors
    flash[:error] = @attachment.errors.to_xml
    attachments
    render :action => :index
  end
end
