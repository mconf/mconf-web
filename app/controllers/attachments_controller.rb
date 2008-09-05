class AttachmentsController < ApplicationController
  # Include some methods and filters.
  include CMS::Controller::Contents
  
  # Authentication Filter
  before_filter :authentication_required, :except => [ :index, :show ]
  
  # Attachments list may belong to a container
  # /attachments
  # /:container_type/:container_id/attachments
  before_filter :get_container, :only => [ :index ]

  # Needs a Container when posting a new Attachment
  before_filter :needs_container, :only => [ :new, :create ]
      
  # Get Attachment in member actions
  before_filter :get_content, :except => [ :index, :new, :create ]
  
   def create
    # Fill params when POSTing raw data
    set_params_from_raw_post
    
    set_params_title_and_description(self.resource_class)
    
    # FIXME: we should look for an existing content instead of creating a new one
    # every time a Content is posted.
    # Idea: Should use SHA1 on one or some relevant Content field(s) 
    # and find_or_create_by_sha1
    @content = instance_variable_set "@#{controller_name.singularize}", self.resource_class.create(params[:content])
    
    @entry = Entry.new(params[:entry].merge({ :agent => current_agent,
      :container => @container,
      :content => @content }))
    
    
    
    respond_to do |format| 
      format.html {
        if !@content.new_record? && @entry.save
          
          tag = params[:tag][:add_tag]    
          @entry.tag_with(tag)
          @entry.category_ids = params[:category_ids]
          flash[:valid] = "#{ @content.class.to_s.humanize } created".t
          redirect_to article_url(@entry)
        else
          @content.destroy unless @content.new_record?
          @collection_path = container_contents_url
          @title ||= "New #{ controller_name.singularize.humanize }".t
          render :template => "articles/new"
        end
      }
      
      format.atom {
        if !@content.new_record? && @entry.save
          headers["Location"] = formatted_article_url(@entry, :atom)
          headers["Content-type"] = 'application/atom+xml'
          render :partial => "articles/entry",
          :status => :created,
          :locals => { :entry => @entry,
            :content => @content },
          :layout => false
        else
          if @content.new_record?
            render :xml => @content.errors.to_xml, :status => :bad_request
          else
            @content.destroy unless @content.new_record?
            render :xml => @entry.errors.to_xml, :status => :bad_request
          end
        end
      }
    end
  end
  
  protected
  def get_space
    @space = @container
  end
end


