class PostsController < ApplicationController
  
  # Posts list may belong to a container
  # /posts
  # /:container_type/:container_id/posts
  before_filter :get_space, :only   => [ :index ]
  before_filter :get_cloud
  # Get Post in member actions
  before_filter :get_post, :except => [ :index, :new, :create ]
  
  # Post media management needs Content supporting media
  before_filter :post_has_media, :only => [ :media, :edit_media ]

  before_filter :get_space_from_container, :only => [ :index, :new, :create ]
  before_filter :get_space_from_post, :only => [ :show, :edit, :update ]

  # Actions different that reading need authentication
  before_filter :authentication_required, :except => [ :index, :show, :media ]
  before_filter :is_public_space, :only=>[:index]
  
  before_filter :get_public_posts, :only => [:index,:show]
# before_filter :space_member, :only=>[:index, :show]
  before_filter :redirect_to_comment, :only => [ :show ]
 
   def index
        if @container
          @title ||= "#{ 'Post'.t('Posts', 99) } - #{ @container.name }"
          # All the Posts this Agent can read in this Container
          @collection = @container.container_posts.find(:all,
                                                        :conditions => [ "content_type = ?", "Attachment" ],
                                                        :order => "updated_at DESC")
          @collection += @container.container_posts.find(:all,
                                                        :conditions => [ "content_type = ?", "XhtmlText" ],
                                                        :order => "updated_at DESC")
          # Paginate them
          @posts = @collection.paginate(:page => params[:page], :per_page => Post.per_page)
          @updated = @collection.blank? ? @container.updated_at : @collection.first.updated_at
          @collection_path = space_posts_url(:container_type => @container.class.to_s.tableize,
                                                 :container_id => @container.id,
                                                 :only_path => false)
        else
          @title ||= 'Post'.t('Posts', 99)
          @posts = Post.paginate :all,
                                      :conditions => [ "public_read = ?", true ],
                                      :page =>  params[:page],
                                      :order => "updated_at DESC"
          @updated = @posts.blank? ? Time.now : @posts.first.updated_at
          @collection_path = url_for :controller => controller_name
        end
    
        respond_to do |format|
          format.html
          format.atom
          format.xml { render :xml => @posts.to_xml.gsub(/cms\/post/, "post") }
        end
      end
 
 # Update this Post metadata
      #   PUT /posts/:id
      def update
       set_params_title_and_description(@post.content) 
        # If the Content of this Post hasn't attachment, update it here
        # If it has, update via media
        # 
        # TODO: find old content when only post params are updated

   # if params[:attachment]!= {"uploaded_data"=>""} #attachment change
    #  @content.update_attributes(params[:attachment])    
    #elsif @content.type == "Attachment"
    # no attachment change and no content change
    #else
   #@content = Article.create(:text => params[:post][:description])
    #end
        # Avoid the user changes container through params
        params[:post][:container] = @post.container
        params[:post][:agent]     = current_agent
        params[:post][:content]   = @content
   
        respond_to do |format|
          format.html {
          #si el contenido es de tipo attachment...
          if @content.class == Attachment
            if !@content.new_record? &&  @post.update_attributes({:description , params[:post][:description],
                :title , params[:title], :public_read , params[:post][:public_read]})
               if params[:attachment]!= {"uploaded_data"=>""} #si hay cambio de attachment
                   @content.update_attributes(params[:attachment])
               end
              tag = params[:tag][:add_tag]    
              @post.tag_with(tag)
              @post.category_ids = params[:category_ids]
              flash[:valid] = "#{ @content.class.to_s.humanize } updated".t
              redirect_to post_url(@post)
            else
              render :template => "posts/edit" 
            end
          #si el contenido es de tipo artículo... 
          elsif @content.class == Article
            
            if params[:attachment]!= {"uploaded_data"=>""} #si se añade un attachment y antes no había
              @content= Attachment.create(params[:attachment])
              params[:post][:content]  = @content
              @post.update_attributes(params[:post]) && @post.update_attribute(:description , params[:content][:text])
              tag = params[:tag][:add_tag]    
              @post.tag_with(tag)
              @post.category_ids = params[:category_ids]
              flash[:valid] = "#{ @content.class.to_s.humanize } updated".t 
              redirect_to post_url(@post)
            
            elsif !@content.new_record? &&  @post.update_attributes(params[:post]) && @content.update_attributes(:text => params[:content][:text])
              tag = params[:tag][:add_tag]    
              @post.tag_with(tag)
              @post.category_ids = params[:category_ids]
              flash[:valid] = "#{ @content.class.to_s.humanize } updated".t
              redirect_to post_url(@post)
            else
              render :template => "posts/edit" 
            end
          else
            #aquí iría el error
             
        end   
          }
    
          format.atom {
            if !@content.new_record? && @post.update_attributes(params[:post])
              head :ok
           #      if params[:attachment]!= {"uploaded_data"=>""}  ###añadido para que añada el texto a la descripción
           #   @post.update_attribute(:description , params[:content][:text])
           #   end
            else
              render :xml => [ @content.errors + @post.errors ].to_xml,
                     :status => :not_acceptable
            end
          }
        end
    end
    
 private
  def redirect_to_comment
    redirect_to(post_path(@post.container, :anchor => "cms_post_#{ @post.id }")) if @post.container.is_a?(Post)
  end

  def get_space_from_container
    session[:current_tab] = "Posts" 
    session[:current_sub_tab] = ""
    @space = @container
  end
  
  def get_space_from_post
    session[:current_tab] = "Posts" 
    session[:current_sub_tab] = ""
    @space = @post.container
  end
end
