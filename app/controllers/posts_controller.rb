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
    unless params[:extended]
      @today = @posts.select{|x| x.updated_at > Date.yesterday}
      @yesterday = @posts.select{|x| x.updated_at > Date.yesterday - 1 && x.updated_at < Date.yesterday}
      @last_week = @posts.select{|x| x.updated_at > Date.today - 7 && x.updated_at < Date.yesterday - 1}
      @older = @posts.select{|x| x.updated_at < Date.today - 7}
    end
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

    @post.space = params[:post][:parent_id] ?
                         @post.parent.space :
                         @space
  
  
    unless @post.valid?
      respond_to do |format|
        format.js{
        if params[:post][:parent_id] #mira si es un comentario o no para hacer el render
            flash[:error] =  t('post.error.not_valid')
            return
          else
            flash[:error] =  t('post.error.empty')
            return
          end
          
        }
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
        format.xml { render :xml => @post.errors, :status => :unprocessable_entity }
        format.atom {render :xml => @post.errors.to_xml, :status => :bad_request}
      end
      return
    end  
    
    #Creación de los Attachments
   if params[:uploaded_data].present?
     @attachment = Attachment.new(:uploaded_data => params[:uploaded_data])
   end
   if @attachment && !@attachment.valid?
     flash[:error] = t('attachment.not_valid')
     respond_to do |format|
       
       format.html{
         posts
         params[:form]="photos"
         render :action => "index"
         return
       }
      end
   end
   
 
=begin    
    i=0;
    @attachments = []
    @last_attachment = params[:last_post] #miro el número de entradas de attachments que se han generado
    (@last_attachment.to_i).times  {
      if params[:"attachment#{i}"]!= nil && params[:"attachment#{i}"]!= {"uploaded_data"=>""} #if post has attachments....
          @attachment = Attachment.new(params[:"attachment#{i}"])
          @attachments << @attachment #almacena referencias de los Attachments nuevos que se están creando
      end
      i += 1
    }
    
    #validamos todos los attachments
    @attachments.each do |attach|
      if !attach.valid?
        flash[:error] = "The attachment is not valid"  
        render :action => "new"
        return
      end
    end
=end

if !@attachment and !@post.text.present?
	 respond_to do |format|
        format.js{
        if params[:post][:parent_id] #mira si es un comentario o no para hacer el render
            flash[:error] = t('post.error.not_valid') 
            return
          else
            flash[:error] = t('post.error.empty')  
            return
          end
          
        }
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
        format.xml { render :xml => @post.errors, :status => :unprocessable_entity }
        format.atom {render :xml => @post.errors.to_xml, :status => :bad_request}
      end
      return
end

    @post.save! #salvamos el artículo y con ello su entrada asociada  
    flash[:success] = t('post.created')
    if @attachment
    @attachment.post = @post
    @attachment.save!
    end
    #asignacion de los padres del attachment al articulo
=begin    @attachments.each do |attach|
      attach.post = @post
    end
 
    #grabación de los attachments y las entries asociados
    @attachments.each do |attach|
      attach.save!
    end
=end              
    respond_to do |format| 
      format.html {
        redirect_to request.referer
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
    #@post.author = current_agent #Problema.Con esto edito al usuario por eso lo cambio
    

    unless @post.valid?
      respond_to do |format|
        format.html {
          flash[:error] = t('post.error.empty')  
          render :action => "edit"
        }
        format.atom { render :xml => @post.errors.to_xml, :status => :not_acceptable }
      end
      return
    end  
=begin        
    #creo los attachments que ha subido el usuario
    i=0;
    @attachments = []
    @last_attachment = params[:last_post] #miro el número de entradas de attachments que se han generado
    (@last_attachment.to_i).times  {
      if params[:"attachment#{i}"]!= nil && params[:"attachment#{i}"]!= {"uploaded_data"=>""} #if post has attachments....
        @attachment = Attachment.new(params[:"attachment#{i}"]) 
        @attachments << @attachment
      end
    i += 1;
    }
=end
       #Creación de los Attachments
   if params[:uploaded_data].present?
     @post.attachments.destroy_all
     @attachment = Attachment.new(:uploaded_data => params[:uploaded_data])
   end
   if @attachment && !@attachment.valid?
        flash[:error] = t('attachment.not_valid') 
        render :action => "index"
        return
   end
   
   
   @post.save! #salvamos el artículo y con ello su entrada asociada  
     flash[:success] = t('post.updated')
    if @attachment
      @attachment.post = @post
      @attachment.save!
    end 
=begin
    #valido los attachments para ver si el contendio es correcto
    @attachments.each do |attach|
    # Attachments list may belong to a container
    # /attachments
    # /:container_type/:container_id/attachments
      if !attach.valid?
        flash[:error] = "The attachment is not valid"  
        render :action => "edit"   
        return
      end
    end 
      
        
    @post.save! #salva el artículo y su entrada asociada        
    flash[:valid] = "Post updated"
           
    #Creación de las entries asociadas a los attachments
    @attachments.each do |attach|
      attach.post = @post
    end 
        
    #Salvamos los attachments y sus entries asociadas
    @attachments.each do |attach|
      attach.save!
    end 
            
     #elimina los attachments quitados al pulsar el botón remove
    @post.attachments.each do |attachment|
      if params[attachment.id.to_s] == "false"
        attachment.destroy
      end
    end
=end           
    respond_to do |format|
      format.html { 
          redirect_to request.referer
      }
      format.atom { head :ok }
    end
  end

  # Delete this Entry
  #   DELETE /spaces/:id/posts/:id --> :method => delete
  def destroy
   #destroy de content of the post. Then its container(post) is destroyed automatic.
   @post.destroy 
    respond_to do |format|
      if !@post.event.nil?
      flash[:notice] = t('post.deleted')  
        format.html {redirect_to space_event_path(@space, @post.event)}
      elsif @post.parent_id.nil?
        flash[:notice] = t('thread.deleted')  
        format.html { redirect_to space_posts_path(@space) }
      else
        flash[:notice] = t('post.deleted')  
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
