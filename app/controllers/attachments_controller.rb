# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.


class AttachmentsController < ApplicationController
  load_and_authorize_resource :space, :find_by => :permalink
  before_filter :load_attachments, :only => [:index, :delete_collection]
  load_and_authorize_resource :attachment, :through => :space
  before_filter :webconf_room!

  layout 'spaces_show'

  def index
    respond_to do |format|
      format.html
      format.zip {
        generate_and_send_zip
      }
    end
  end

  def new
    respond_to do |format|
      format.html {
        render :partial => "upload_form"
      }
    end
  end

  # TODO: do not remove anything if attachment_ids is not informed (it's removing all attachments)
  def delete_collection
    if @attachments.blank?
      flash[:error] = t("attachment.error.malformed")
      redirect_to space_attachments_path(@space)
    else
      errors = ""
      @attachments.each do |attachment|
        if can?(:destroy, attachment)
          unless attachment.delete
            errors += t("attachment.error.not_deleted", :file => attachment.title)
          end
        else
          errors += t("attachment.error.not_permission", :file => attachment.title, :user => current_user.username)
        end
      end
      if errors.blank?
        flash[:success] = t("attachment.deleted")
      else
        flash[:error] = errors
      end

      redirect_to space_attachments_path(@space)
    end
  end

  def create
    @attachment.author = current_user
    @attachment.space = @space

    respond_to do |format|
      if @attachment.save
        format.html {
          flash[:success] = t('attachment.created')
          redirect_to space_attachments_path(@space)
        }
      else
        format.html {
          flash[:error] = @attachment.errors.to_xml
          render :action => :index
          flash.delete([:error])
        }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @attachment.destroy
        format.html {
          flash[:success] = t('attachment.deleted')
          redirect_to space_attachments_path(@space)
        }
      else
        format.html {
          flash[:error] = t('attachment.error.not_deleted')
          flash[:error] << @attachment.errors.to_xml
          redirect_to(request.referer || space_attachments_path(@space))
        }
      end
    end
  end

  private

  def load_attachments
    # shows the newer items in the top by default
    params[:order] ||= "created_at"
    params[:direction] ||= "asc"
    @attachments = Attachment.repository_attachments(@space, params)
  end

  def generate_and_send_zip
    require 'zip/zip'
    require 'zip/zipfilesystem'

    t = Tempfile.new("#{@attachments.size}files-#{Time.now.to_f}.zip")

    Zip::ZipOutputStream.open(t.path) do |zos|
      @attachments.each do |file|
        zos.put_next_entry(file.title)
        zos.print IO.read(file.full_filename)
      end
    end

    send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => t('attachment.filename', :size => @attachments.size, :name => @space.name)

    t.close
  end

end
