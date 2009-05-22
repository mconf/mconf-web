class PostsController < ApplicationController
  # Include some methods and set some default filters. 
  # See documentation: ActionController::MoveResources
  include ActionController::MoveResources
  
  set_params_from_atom :post, :only => [ :create, :update ]
  
  # Posts list belong to a space
  # /posts
  # /:container_type/:container_id/posts, :new, :create
  before_filter :space, :only => [ :index, :destroy, :show ,:update  ]
  
  # Needs a Container when posting a new Post
  before_filter :space!, :only => [ :new, :create ]
  
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
      post_with_children(post, {:last => true})
    else
      post_with_children(post)  
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
    session[:current_sub_tab] = "New post"
    @post = Post.new
    @title ||= "New Post"
  end

  # Renders form for editing this Entry metadata
  #   GET /posts/:id/edit
  def edit
    @attachment_children = @post.attachments
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
            flash[:error] = "The comment is not valid" 
            return
          else
            flash[:error] = "The content of the post can't be empty"  
            return
          end
          
        }
        format.html {   
          if params[:post][:parent_id] #mira si es un comentario o no para hacer el render
            flash[:error] = "The comment is not valid" 
            posts
            render :action => "index"

          else
            flash[:error] = "The content of the post can't be empty"
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
     flash[:error] = "The attachment is not valid"
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
if @post.text.present?
	 respond_to do |format|
        format.js{
        if params[:post][:parent_id] #mira si es un comentario o no para hacer el render
            flash[:error] = "The comment is not valid" 
            return
          else
            flash[:error] = "The content of the post can't be empty"  
            return
          end
          
        }
        format.html {   
          if params[:post][:parent_id] #mira si es un comentario o no para hacer el render
            flash[:error] = "The comment is not valid" 
            posts
            render :action => "index"

          else
            flash[:error] = "The content of the post can't be empty"
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
    flash[:success] = "Post created"
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
          post_with_children(@post, :last => true)
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
          flash[:error] = "The content of the post can't be empty"  
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
        flash[:error] = "The attachment is not valid"  
        render :action => "index"
        return
   end
   
   
   @post.save! #salvamos el artículo y con ello su entrada asociada  
     flash[:success] = "Post updated"
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
   flash[:notice] = "Post has been deleted"
    respond_to do |format|
      format.html { redirect_to space_posts_path(@space) }
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
   @posts ||= Post.parents.in_container(@space).find(:all, 
                                                     :order => "updated_at DESC"
                                                   ).paginate(:page => params[:page],
                                                              :per_page => 5)       
  
  end

  def post_with_children(parent_post, options = {})
    total_posts = Array(parent_post).concat(parent_post.children)
    per_page = 5
    page = params[:page] || options[:last] && total_posts.size.fdiv(per_page).ceil

    @posts ||= total_posts.paginate(:page => page, :per_page => per_page)
  end

end
