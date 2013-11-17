# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.


class AttachmentsController < ApplicationController
  before_filter :space!
  before_filter :webconf_room!
  before_filter :except => [ :new, :edit ]
  load_and_authorize_resource :space, :find_by => :permalink
  load_and_authorize_resource :attachment, :through => :space

  layout 'spaces_show'

  def index
    # gon usage for making @space and other variables available to js
    gon.clear
    gon.space = @space
    # TODO see better way to use paths with gon
    gon.attachments_path = space_attachments_path(@space)
    gon.form_auth_token = form_authenticity_token()
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
    respond_to do |format|
      format.html {
        render :partial => "edit_tags_form"
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

  def edit
    respond_to do |format|
      format.html {
        render :partial => "edit"
      }
    end
  end

  def delete_collection
    if params[:attachment_ids].blank?
      flash[:error] = "Malformed request"
      redirect_to space_attachments_path(@space)
    else
      attachments
      errors = ""
      @attachments.each do |attachment|
        if can?(:destroy, attachment)
          attachment.tags.each do |tag|
            tag.delete
          end
          unless attachment.delete
            errors += I18n.t("attachment.error.not_deleted", :file => attachment.filename)
          end
        else
          errors += I18n.t("attachment.error.not_permission", :file => attachment.filename, :user => current_user.username)
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


  # TODO: code below taken from station's ActionController::StationResources

  # Show this Content
  #
  #   GET /resources/1
  #   GET /resources/1.xml
  def show
    if params[:version] && resource.respond_to?(:versions)
      resource.revert_to(params[:version].to_i)
    end

    if params[:thumbnail] && resource.respond_to?(:thumbnails)
      @resource = resource.thumbnails.find_by_thumbnail(params[:thumbnail])
    end

    instance_variable_set "@#{ model_class.to_s.underscore }", resource

    respond_to do |format|
      format.all {
        send_data resource.__send__(:current_data),
        :filename => resource.filename,
        :type => resource.content_type,
        :disposition => resource.class.resource_options[:disposition].to_s
      } if resource.class.resource_options[:has_media]

      format.html # show.html.erb

      # Add Resource format Mime Type for resource with Attachments
      format.send(resource.mime_type.to_sym.to_s) {
        send_data resource.__send__(:current_data),
        :filename => resource.filename,
        :type => resource.content_type,
        :disposition => resource.class.resource_options[:disposition].to_s
      } if resource.mime_type

    end
  end

  # Create new Resource
  #
  #   POST /resources
  #   POST /resources.xml
  #   POST /:container_type/:container_id/contents
  def create
    # Fill params when POSTing raw data
    set_params_from_raw_post

    resource_params = params[model_class.to_s.underscore.to_sym]
    resource_class =
      model_class.resource_options[:delegate_content_types] &&
      resource_params[:media] && resource_params[:media].present? &&
      ActiveRecord::Resource.class_supporting(resource_params[:media].content_type) ||
      model_class

    @resource = resource_class.new(resource_params)
    instance_variable_set "@#{ model_class.to_s.underscore }", @resource

    @resource.author = current_user if @resource.respond_to?(:author=)
    @resource.container = @space #  if @resource.respond_to?(:container=)

    respond_to do |format|
      if @resource.save
        format.html {
          flash[:success] = t(:created, :scope => @resource.class.to_s.underscore)
          after_create_with_success
        }
      else
        format.html {
          after_create_with_errors
        }
      end
    end
  end

  # Update Resource
  #
  # PUT /resources/1
  # PUT /resources/1.xml
  def update
    # Fill params when POSTing raw data
    set_params_from_raw_post

    resource.attributes = params[model_class.to_s.underscore.to_sym]
    resource.author = current_user if resource.respond_to?(:author=) && resource.changed?

    respond_to do |format|
      #FIXME: DRY
      format.all {
        if resource.save
          head :ok
        else
          render :xml => @resource.errors.to_xml, :status => :not_acceptable
        end
      }

      format.html {
        if resource.save
          flash[:success] = t(:updated, :scope => @resource.class.to_s.underscore)
          after_update_with_success
        else
          after_update_with_errors
        end
      }
      format.send(resource.format) {
        if resource.save
          head :ok
        else
          render :xml => @resource.errors.to_xml, :status => :not_acceptable
        end
      } if resource.format
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.xml
  def destroy
    respond_to do |format|
      if resource.destroy
        format.html {
          flash[:success] = t(:deleted, :scope => @resource.class.to_s.underscore)
          redirect_to space_attachments_path(@space)
        }
      else
        format.html {
          flash[:error] = t(:not_deleted, :scope => resource.class.to_s.underscore)
          flash[:error] << resource.errors.to_xml
          redirect_to(request.referer || space_attachments_path(@space))
        }
      end
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


  # TODO: taken from station's ActionController::StationResources
  def resource
    @resource ||= Attachment.find(params[:id])
  end

  # TODO: taken from station
  def path_containers(options = {})
    @path_containers ||= records_from_path(:acts_as => :container)

    candidates = options[:ancestors] ?
    @path_containers.map{ |c| c.container_and_ancestors }.flatten.uniq :
      @path_containers.dup

    filter_type(candidates, options[:type])
  end

  # TODO: taken from station
  def path_container(options = {})
    path_containers(options).first
  end

end
