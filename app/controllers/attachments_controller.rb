class AttachmentsController < ApplicationController
  include ActionController::StationResources
  
  # Always needs a space
  before_filter :space!
  authorization_filter :create, :attachment, :only => [ :new, :create ]
  authorization_filter :read,   :attachment, :only => [ :index, :show ]
  authorization_filter :update, :attachment, :only => [ :edit, :update ]
  authorization_filter :delete, :attachment, :only => [ :destroy ]
  
  def index
    attachments
  end

  def edit_tags
    @attachment = Attachment.find(params[:id])
  end

  private

  def attachments
    @attachments,@tags = Attachment.repository_attachments(@space, params)
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
    flash.delete([:error])
  end
 
  def after_update_with_errors
    flash[:error] = @attachment.errors.to_xml
    attachments
    render :action => :index
    flash.delete([:error])
  end
end
