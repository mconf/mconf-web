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
  
  before_filter :get_post, :except => [ :index, :new, :create ]
  before_filter :get_public_posts, :only => [:index,:show]
  # Get Article in member actions
  before_filter :get_content, :except => [ :index, :new, :create, :search_articles ]
  #before_filter :is_public_space, :only=>[:index]
  before_filter :get_space
  #before_filter :get_space_from_post, :only => [ :show, :edit, :update ]
  before_filter :get_cloud
  
  def index
     session[:current_tab] = "Posts"
     session[:current_sub_tab] = ""
     
        if @container
          @title ||= "#{ 'Post'.t('Posts', 99) } - #{ @container.name }"
          # All the Posts this Agent can read in this Container
          @collection = @container.container_posts.find(:all,
                                                        :conditions => { :content_type => "XhtmlText" , :parent_id => nil },
                                                        :order => "updated_at DESC")
          
          # Paginate them
          @posts = @collection.paginate(:page => params[:page], :per_page => Post.per_page)
          @updated = @collection.blank? ? @container.updated_at : @collection.first.updated_at
          @collection_path = space_articles_path(@container)
        else
          @title ||= 'Post'.t('Posts', 99)
          @posts = Post.paginate :all,
                                      :conditions => [ "public_read = ?", true ],
                                      :page =>  params[:page],
                                      :order => "updated_at DESC"
          @updated = @posts.blank? ? Time.now : @posts.first.updated_at
          @collection_path = articles_path
        end
    
        respond_to do |format|
          format.html
          format.atom
          format.xml { render :xml => @posts.to_xml.gsub(/cms\/post/, "post") }
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
      
    @content = Article.create(params[:content])
    @post = Post.create(params[:post].merge({ :agent => current_agent,
        :container => @container,
        :content => @content,
        :description => params[:content][:text]})) 
    
    if params[:attachment]!= {"uploaded_data"=>""} #if post has attachments....
      @attachment_content = Attachment.create(params[:attachment]) 
       @attachment_post = @post.children.new({ :agent => current_agent,
        :container => @container,
        :content => @attachment_content, 
        :description => params[:content][:text],
        :title => params[:title],
        :parent_type => @post.content,
        :public_read => params[:post][:public_read]})
      
    end    
    respond_to do |format| 
      format.html {
        if !@content.new_record? && @post.save ####Siempre comprueba el post padre  
          if params[:attachment] != {"uploaded_data"=>""}    #####Si tiene attachment, comprueba si se han salvado bien
            if !@attachment_content.new_record? && @attachment_post.save  
            else
            @attachment_content.destroy unless @attachment_content.new_record?
            @attachment_post.destroy
            @collection_path = container_contents_url
            @title ||= "New #{ controller_name.singularize.humanize }".t
            end
          end
          tag = params[:tag][:add_tag]    
          @post.tag_with(tag)
          @post.category_ids = params[:category_ids]
          flash[:valid] = "#{ @content.class.to_s.humanize } created".t
          if params[:post][:parent_id] == nil
            redirect_to space_article_url(@container.id, @post.content_id)
          else
            redirect_to space_article_url(@container.id, @post.parent.content)
          end
          
        else
          @content.destroy unless @content.new_record?
          @collection_path = container_contents_url
          @title ||= "New #{ controller_name.singularize.humanize }".t
          if @container.class == Post 
          
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
  
  def new 
        session[:current_sub_tab] = "New article"
        @collection_path = space_articles_path
        @post = Post.new
        @post.content = @content = instance_variable_set("@#{controller_name.singularize}", controller_name.classify.constantize.new)
        @title ||= "New #{ controller_name.singularize.humanize }".t
        render :template => "articles/new"
  end
  
     # Show this Post
      #   GET /posts/:id
      def show
        
        @title ||= @post.title
        @comment_children = @post.children.select{|c| c.content.is_a? Article}
        @attachment_children = @post.children.select{|c| c.content.is_a? Attachment}
        
        respond_to do |format|
          format.html
          format.xml { render :xml => @post.to_xml(:include => [ :content ]) }
          format.atom { 
            headers["Content-type"] = 'application/atom+xml'
            render :partial => "posts/entry",
                               :locals => { :post => @post },
                               :layout => false
          }
          format.json { render :json => @post.to_json(:include => :content) }
        end
    end
    
      # Delete this Post
  #   DELETE /spaces/:id/articles/:id --> :method => delete
  def destroy
    
    #destroy de content of the post. Then its container(post) is destroyed automatic.
   @article.destroy 
    respond_to do |format|
      format.html { redirect_to space_articles_path(@container) }
      format.atom { head :ok }
      # FIXME: Check AtomPub, RFC 5023
#      format.send(mime_type) { head :ok }
      format.xml { head :ok }
    end
  end
   # Renders form for editing this Post metadata
      #   GET /posts/:id/edit
      def edit
        get_params_title_and_description(@post)
        params[:category_ids] = @post.category_ids
    
        render :template => "articles/edit"
      end
  
  # Update this Post metadata
      #   PUT /posts/:id
      def update       
       set_params_title_and_description(@post.content) 
        # If the Content of this Post hasn't attachment, update it here
        # If it has, update via media
        # 
        # TODO: find old content when only post params are updated

        # Avoid the user changes container through params
        params[:post][:container] = @post.container
        params[:post][:agent]     = current_agent
        params[:post][:content]   = @content
   
        respond_to do |format|
          format.html {
             
            if params[:attachment]!= {"uploaded_data"=>""} #si se añade un attachment....
              @attachment_content= Attachment.create(params[:attachment])
              @attachment_post = @post.children.new({ :agent => current_agent,
                  :container => @container,
                  :content => @attachment_content, 
                  :description => params[:content][:text],
                  :title => params[:title],
                  :parent_type => @attachment_content.type,
                  :public_read => params[:post][:public_read]})

              @post.update_attributes(params[:post]) && @post.update_attribute(:description , params[:content][:text]) && @attachment_post.save && @content.update_attributes(:text => params[:content][:text])
              tag = params[:tag][:add_tag]    
              @post.tag_with(tag)
              @post.category_ids = params[:category_ids]
              flash[:valid] = "#{ @content.class.to_s.humanize } updated".t 
              redirect_to space_article_path(@container,@post.content)
            
            elsif !@content.new_record? &&  @post.update_attributes(params[:post]) && @post.update_attribute(:description , params[:content][:text]) && @content.update_attributes(:text => params[:content][:text])
              tag = params[:tag][:add_tag]    
              @post.tag_with(tag)
              @post.category_ids = params[:category_ids]
              flash[:valid] = "#{ @content.class.to_s.humanize } updated".t
              redirect_to space_article_path(@container,@post.content)
            else
              render :template => "articles/edit" 
            end
         # else
            #the error here
             
        #end   
          }
    
          format.atom {
            if !@content.new_record? && @post.update_attributes(params[:post])
              head :ok
            else
              render :xml => [ @content.errors + @post.errors ].to_xml,
                     :status => :not_acceptable
            end
          }
        end
    end
  private
  def get_space_from_container
    session[:current_tab] = "Posts" 
    @space = @container
  end
  #he añadido aquí el get_post pero no me gusta un pelo
  def get_post 
         @article = Article.find(params[:id])
         @post = Post.find(:first,:conditions => {:content_id => @article.id})
         
       end
  
  #def get_space_from_post
    #session[:current_tab] = "Posts" 
    #@space = @post.container
  #end
  
end
