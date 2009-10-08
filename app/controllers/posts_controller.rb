class PostsController < ApplicationController
  # Include basic Resource methods
  # See documentation: ActionController::StationResources
  include ActionController::StationResources
  include SpamControllerModule 
  
  set_params_from_atom :post, :only => [ :create, :update ]
  
  # Posts needs a Space. It will respond 404 if no space if found
  before_filter :space!
  
  before_filter :post, :except => [ :index, :new, :create]
  
  authorization_filter [ :read, :content ],   :space, :only => [ :index ]
  authorization_filter [ :create, :content ], :space, :only => [ :new, :create ]
  authorization_filter :read,   :post, :only => [ :show ]
  authorization_filter :update, :post, :only => [ :edit, :update ]
  authorization_filter :delete, :post, :only => [ :destroy ]
  
  def index
    posts
    respond_to do |format|
      format.html 
      format.atom 
      format.xml { render :xml => @posts }
    end
  end
  
  # Show this Entry
  #   GET /posts/:id
  def show
    if params[:last_page]
      post_comments(post, {:last => true})
    else
      post_comments(post)  
    end
    
    respond_to do |format|
      format.html {
        if request.xhr?
          if params[:edit]
            if !post.attachments.empty? 
              if !post.attachments.select{|a| a.image?}.empty?     
                params[:form]='photos'
              else
                params[:form]='docs'
              end
            end
            if post.parent_id
              render :partial => "edit_reply", :locals => { :post => post }
            else
              render :partial => "edit_thread", :locals => { :post => post }
            end
          else
            render :partial => "new_reply", :locals => { :post => @post }  
          end
        else
          @show_view = true  
        end
      }
      format.xml { render :xml => @post.to_xml }
      format.atom 
      format.json { render :json => @post.to_json }
    end
  end
  
  def new
    @post = Post.parent_scoped.in_container(@space).find(params[:reply]) if params[:reply]
    
    respond_to do |format|
      format.html {
        if params[:reply]
          if request.xhr?
            render "new_reply_big", :layout => false
          else
            render "new_reply_big"
          end
        else
          if request.xhr?
            render "new_thread_big", :layout => false
          else
            render "new_thread_big"
          end
        end
      }
    end  
  end
  
  # Renders form for editing this Entry metadata
  #   GET /posts/:id/edit
  def edit
    respond_to do |format|
      format.html {
        if @post.parent.nil?
          if request.xhr?
            render "edit_thread_big", :layout => false
          else
            render "edit_thread_big"
          end
        else
          if request.xhr?
            render "edit_reply_big", :layout => false
          else
            render "edit_reply_big"
          end
        end
      }
    end 
  end
  
  def create
    if params[:parent_post]
      params[:post] = params[:parent_post]
    end
    #creación del Artículo padre
    @post = Post.new(params[:post])
    @post.author = current_agent
    # Para comentarios desde el espacio Public
    # FIXME? Quitar si se elimina el espacio Public
    
    @post.space = params[:post][:parent_id] ? @post.parent.space : @space
    
    
    #Creación de los Attachments
    if params[:uploaded_data].present?
      @attachment = Attachment.new(:uploaded_data => params[:uploaded_data])
      if @attachment 
        if !@attachment.valid?
          flash[:error] = t('attachment.not_valid')
          respond_to do |format|
            format.html{
              posts
              params[:form]="photos"
              render :action => "index"
              return
            }
          end
        else
          @attachment.space = @space
          @attachment.author = current_agent
#          @attachment.save;
        end
      end
    end
    
    #    unless ( @post.valid? && ((@attachment && @attachment.valid?) || @post.text.present?))
    unless  @post.valid?  && ((@attachment && @attachment.valid?) || @post.text.present?)
      respond_to do |format|
        format.html {   
          if params[:post][:parent_id] #mira si es un comentario o no para hacer el render
            flash[:error] = t('post.error.not_valid') 
            posts
            render :action => "index"
            
          else
            flash[:error] = t('post.error.empty')
            posts
            render :action => "index"
            
          end
        }
        format.js{
          if params[:post][:parent_id] #mira si es un comentario o no para hacer el render
            flash[:error] =  t('post.error.not_valid')
            return
          else
            flash[:error] =  t('post.error.empty')
            return
          end
          
        }
        format.xml { render :xml => @post.errors, :status => :unprocessable_entity }
        format.atom {render :xml => @post.errors.to_xml, :status => :bad_request}
      end
      return
    end
    
    
    @post.save! #salvamos el artículo y con ello su entrada asociada  
    flash[:success] = t('post.created')
    if(@attachment) 
      @attachment.post = @post
      @attachment.save!
    end
    
    respond_to do |format| 
      format.html {
        redirect_to(request.referer || space_posts_path)
      }
      format.js {
        if params[:show]
          @new_post = @post
          @post = @post.parent
          post_comments(@post, :last => true)
        else
          posts
        end
      }
      format.atom { 
        headers["Location"] = formatted_space_post_url(@space, @post, :atom )
        render :action => :show,
               :status => :created
      }
    end
  end
  
  # Update this Entry metadata
  #   PUT /posts/:id
  def update       
    #actualizo los atributos del artículo
    @post.attributes = params[:post]
    
    
    if params[:uploaded_data].present?
      @attachment = Attachment.new(:uploaded_data => params[:uploaded_data])
      if @attachment 
        if !@attachment.valid?
          flash[:error] = t('attachment.not_valid')
          respond_to do |format|
            format.html{
              posts
              params[:form]="photos"
              render :action => "index"
              return
            }
          end
        else
          @attachment.space = @space
          @attachment.author = current_agent
        end
      end
    end
    
    unless @post.valid?  && ((@attachment && @attachment.valid?) || (!@attachment && @post.attachments) || @post.text.present?)
      respond_to do |format|
        format.html {   
          flash[:error] = t('post.error.empty')
          posts
          render :action => "index"
        }
        format.xml { render :xml => @post.errors, :status => :unprocessable_entity }
        format.atom {render :xml => @post.errors.to_xml, :status => :not_acceptable}
      end
      return
    end
    
    
    @post.save! #salvamos el artículo y con ello su entrada asociada  
    flash[:success] = t('post.updated')
    if(@attachment) 
      @post.attachments.destroy_all
      @attachment.post = @post
      @attachment.save
    @post.save! #salvamos el artículo y con ello su entrada asociada  
    end
    
    respond_to do |format|
      format.html { 
        redirect_to(request.referer || space_posts_path)
      }
      format.atom { head :ok }
    end
    
  end
  
  # Delete this Entry
  #   DELETE /spaces/:id/posts/:id --> :method => delete
  #destroy de content of the post. Then its container(post) is destroyed automatic.
  def destroy
    @post.destroy 
    respond_to do |format|
      if !@post.event.nil?
        flash[:notice] = t('post.deleted', :postname => @post.title)  
        format.html {redirect_to space_event_path(@space, @post.event)}
      elsif @post.parent_id.nil?
        flash[:notice] = t('thread.deleted')  
        format.html { redirect_to space_posts_path(@space) }
      else
        flash[:notice] = t('post.deleted', :postname => @post.title)  
        format.html { redirect_to request.referer }
      end  
      format.js 
      format.atom { head :ok }
      # FIXME: Check AtomPub, RFC 5023
      #      format.send(mime_type) { head :ok }
      format.xml { head :ok }
    end
  end
  
  private
  
  # DRY (used in index and create.js)
  def posts
    per_page = params[:extended] ? 6 : 15
    @posts ||= Post.parent_scoped.in_container(@space).not_events().find(:all, 
                                                     :order => "updated_at DESC"
    ).paginate(:page => params[:page],
                                                              :per_page => per_page)       
    
  end
  
  def post_comments(parent_post, options = {})
    total_posts = parent_post.children
    per_page = 5
    page = params[:page] || options[:last] && total_posts.size.to_f./(per_page).ceil
    page = nil if page == 0
    
    @posts ||= total_posts.paginate(:page => page, :per_page => per_page)
  end
  
end
