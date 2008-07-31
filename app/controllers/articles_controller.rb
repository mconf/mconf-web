class ArticlesController < ApplicationController
  # Include some methods and set some default filters. 
  # See documentation: CMS::Controller::Contents#included
  include CMS::Controller::Contents
  
  # Articles list may belong to a container
  # /articles
  # /:container_type/:container_id/articles
  before_filter :get_container, :only => [ :index,:search_articles  ]
  
  # Needs a Container when posting a new Article
  before_filter :needs_container, :only => [ :new, :create ]
  
  # Get Article in member actions
  before_filter :get_content, :except => [ :index, :new, :create, :search_articles ]
  #before_filter :is_public_space, :only=>[:index]
  before_filter :get_space, :only => [ :index, :new, :create ,:search_articles ]
  before_filter :get_space_from_post, :only => [ :show, :edit, :update ]
  before_filter :get_cloud
  
  
  def search_articles
    @query = params[:query]    
    @results = Article.find_by_contents(@query)
    @pos = @container.container_posts    
    @posts = []   
    @results.collect { |result|
      post = CMS::Post.find_by_content_type_and_content_id("CMS::Text", result.id)
      if @pos.include?(post)
        @posts << post
      end
    }
    respond_to do |format|   
      format.html {render :template=>'/articles/search_articles'}
      format.js 
    end
  end
  def create
    # Fill params when POSTing raw data
    set_params_from_raw_post
    
    set_params_title_and_description(self.resource_class)
    
    # FIXME: we should look for an existing content instead of creating a new one
    # every time a Content is posted.
    # Idea: Should use SHA1 on one or some relevant Content field(s) 
    # and find_or_create_by_sha1
    if params[:attachment]!= {"uploaded_data"=>""}
      @content = Attachment.create(params[:attachment])  
        @post = CMS::Post.new({ :agent => current_agent,
        :container => @container,
        :content => @content, 
        :description => params[:content][:text],
        :title => params[:post][:title],
        :public_read => params[:post][:public_read]}) 
    else
    
      @content = instance_variable_set "@#{controller_name.singularize}", self.resource_class.create(params[:content])
       @post = CMS::Post.new(params[:post].merge({ :agent => current_agent,
        :container => @container,
        :content => @content}))
    end
    #if params[:attachment] != nil 
    #@attachment = Attachment.new(params[:attachment])# añadida por mi....
  
    #@attachment.save;

    #@attachment_post = CMS::Post.new( :agent => current_agent,
     # :container_type =>"CMS::Post",
     # :container_id => @content.id,
     # :content => @attachment,
     # :title => @post.title,
     # :description => @post.description)
 
    #end 
    respond_to do |format| 
      format.html {
      #lo de abajo lo he modificado
        if !@content.new_record? & @post.save ####ojo, igual es peligroso  
        #  if params[:attachment] != nil    #####compruebo que se graban y no da error
        #    @attachment.save && @attachment_post.save   
        #  end
          tag = params[:tag][:add_tag]    
          @post.tag_with(tag)
          @post.category_ids = params[:category_ids]
          flash[:valid] = "#{ @content.class.to_s.humanize } created".t
          redirect_to post_url(@post)
        else
          @content.destroy unless @content.new_record?
          @collection_path = container_contents_url
          @title ||= "New #{ controller_name.singularize.humanize }".t
          if @container.class == CMS::Post 
          
            @post_ = @post
            @post = @container
            @errors = true
            render :template => "posts/show" , :object => {@errors, @post_}
          else
          @errors = true
          @post_= @post
            render :template => "posts/new" , :object => {@post_, @errors}
          end
        end
      }
      
      format.atom {
        if !@content.new_record? & @post.save 
         #  if params[:attachment] != nil    #####compruebo que se graban y no da error
         #   @attachment.save && @attachment_post.save   
         # end
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
  
  private
  def get_space_from_container
    session[:current_tab] = "Posts" 
    @space = @container
  end
  
  def get_space_from_post
    session[:current_tab] = "Posts" 
    @space = @post.container
  end
  
end
