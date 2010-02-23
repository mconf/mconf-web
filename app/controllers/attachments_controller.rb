# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.


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
    respond_to do |format|
      format.html
      format.zip{
        generate_and_send_zip
      }
    end
  end

  def edit_tags
    @attachment = Attachment.find(params[:id])
  end

  def delete_collection
    
    if params[:attachment_ids].blank?
      flash[:error] = "Malformed request"  
      redirect_to space_attachments_path(@space)
    else
      attachments
      errors = ""
      @attachments.each do |attachment|
        if attachment.authorize?(:delete, :to => current_user)
          unless attachment.delete
            errors += I18n.t("attachment.error.not_deleted", :file => attachment.filename)
          end
        else
          errors += I18n.t("attachment.error.not_permission", :file => attachment.filename, :user => current_user.login)
        end
      end
      if errors==""
        flash[:success] = I18n.t("attachment.deleted")
      else
        flash[:error] = errors
      end
      
      redirect_to space_attachments_path(@space)
    end
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
  
  def generate_and_send_zip
    require 'zip/zip'
    require 'zip/zipfilesystem'
  
    t = Tempfile.new("#{@attachments.size}files-#{Time.now.to_f}.zip")
    
    Zip::ZipOutputStream.open(t.path) do |zos|
      @attachments.each do |file|
        zos.put_next_entry(file.filename)
        zos.print IO.read(file.full_filename)
      end
    end

    send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => "#{@attachments.size} files from #{@space.name}.zip"
    
    t.close
  end
  
end
