# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.


class AttachmentsController < ApplicationController
  # anonymous users can view and download attachments
  before_filter :authenticate_user!, except: [:index, :show]

  load_and_authorize_resource :space, :find_by => :permalink
  before_filter :check_repository_enabled
  load_and_authorize_resource :through => :space, :except => [:index, :delete_collection]
  before_filter :load_attachments, :only => [:index, :delete_collection]
  before_filter :webconf_room!, :only => [:index]

  layout 'spaces_show'

  def show
    path = @attachment.full_filename
    send_file path
  end

  def index
    respond_to do |format|
      format.html
      format.zip {
        generate_and_send_zip
      }
    end
  end

  def new
    render layout: false
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
    @attachment.attachment = params[:uploaded_file]

    success = @attachment.save
    redirect = space_attachments_path(@space)
    respond_to do |format|
      format.html { redirect_to redirect }
      format.json { render :json => {:success => success, :redirect_url => redirect }, :status => 200 }
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

  def check_repository_enabled
    unless @space.repository?
      redirect_to space_path(@space), :notice => t('attachment.repository_disabled')
    end
  end

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
