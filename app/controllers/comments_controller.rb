class CommentsController < ApplicationController
  # Include some methods and filters.
  include CMS::Controller::Contents
  
  # Authentication Filter
  before_filter :authentication_required, :except => [ :index, :show ]
  
  # Comments list may belong to a container
  # /comments
  # /:container_type/:container_id/comments
  before_filter :get_container, :only => [ :index ]

  # Needs a Container when posting a new Comment
  before_filter :needs_container, :only => [ :new, :create ]
      
  # Get Comment in member actions
  before_filter :get_content, :except => [ :index, :new, :create ]
  before_filter :get_space
  
  def create
    
     # Fill params when POSTing raw data
        set_params_from_raw_post
    
        set_params_title_and_description(self.resource_class)
    
        # FIXME: we should look for an existing content instead of creating a new one
        # every time a Content is posted.
        # Idea: Should use SHA1 on one or some relevant Content field(s) 
        # and find_or_create_by_sha1
        
        @content = instance_variable_set "@#{controller_name.singularize}", self.resource_class.create(params[:content])
    
        @post = CMS::Post.new(params[:post].merge({ :agent => current_agent,
                                                    :container => @container,
                                                    :content => @content }))
    
        respond_to do |format| 
          format.html {
            if !@content.new_record? && @post.save
              flash[:message] = "#{ @content.class.to_s } created"
             
              if @post.container_type == 'Article'
                
                redirect_to article_comments_url(@container)
             
              else
              redirect_to post_url(@post)
              end
            else
              @content.destroy unless @content.new_record?
              @collection_path = container_contents_url
              render :template => "posts/new"
            end
          }
    
          format.atom {
            if !@content.new_record? && @post.save
        headers["Location"] = formatted_post_url(@post, :atom)
        headers["Content-type"] = 'application/atom+xml'
              render :partial => "posts/entry",
                                 :status => :created,
                                 :locals => { :post => @post,
                                              :content => @content },
                                 :layout => false
            else
              if @content.new_record?
                render :xml => @content.errors.to_xml, :status => :bad_request
              else
                @content.destroy unless @content.new_record?
                render :xml => @post.errors.to_xml, :status => :bad_request
              end
            end
          }
        end
      
  end
end
