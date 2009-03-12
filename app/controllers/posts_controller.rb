class PostsController < ApplicationController
  # Include some methods and set some default filters. 
  # See documentation: ActionController::MoveResources
  include ActionController::MoveResources
  
  set_params_from_atom :post, :only => [ :create, :update ]
  
  # Posts list may belong to a container
  # /posts
  # /:container_type/:container_id/posts
  before_filter :space, :only => [ :index,:search_posts  ]
  
  # Needs a Container when posting a new Post
  before_filter :space!, :only => [ :new, :create ]
  
  before_filter :get_post, :except => [ :index, :new, :create ]

  #authorization_filter :space, [ :read,   :Content ], :only => [ :index ]
  #authorization_filter :space, [ :create, :Content ], :only => [ :new, :create ]
  #authorization_filter :post, :read,   :only => [ :show ]
  #authorization_filter :post, :update, :only => [ :edit, :update ]
  #authorization_filter :post, :delete, :only => [ :destroy ]

  def index
  #Estas 3 líneas lo que hacen es meter en @posts lo que hay en la linea 2 si el espacio es el público y si no, mete lo de la línea 3
    @posts =(@space.id == 1 ?
      Post.in_container(nil).public(nil).find(:all,:conditions => {"parent_id" => nil}, :order => "updated_at DESC").paginate(:page => params[:page], :per_page => params[:per_page]):       
      Post.in_container(@space).find(:all, :conditions => {"parent_id" => nil}, :order => "updated_at DESC").paginate(:page => params[:page], :per_page => params[:per_page]))       
    
      respond_to do |format|
        format.html 
        format.atom 
        format.xml { render :xml => @posts }
    end
  end

  # Show this Entry
  #   GET /posts/:id
  def show
    session[:current_tab] = "News"

    @title ||= @post.title
    @comment_children = @post.children
    @attachment_children = @post.attachments
    
    respond_to do |format|
      format.html
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
    #creación del Artículo padre
    @post = Post.new(params[:post])
    @post.author = current_agent
    # Para comentarios desde el espacio Public
    # FIXME? Quitar si se elimina el espacio Public
    @post.space = params[:post][:parent_id] ?
                         @post.parent.space :
                         @container
    
    unless @post.valid?
      respond_to do |format|
        format.html {   
          if params[:post][:parent_id] #mira si es un comentario o no para hacer el render
            flash[:error] = "The comment is not valid" 
            render :action => "new"
          else
            flash[:error] = "The content of the post can't be empty"  
            render :action => "new"                
          end
        }
        format.xml { render :xml => @post.errors, :status => :unprocessable_entity }
        format.atom {render :xml => @post.errors.to_xml, :status => :bad_request}
      end
      return
    end  
    
    #Creación de los Attachments
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
      

    @post.save! #salvamos el artículo y con ello su entrada asociada  
    flash[:valid] = "Post created"
 

    #asignacion de los padres del attachment al articulo
    @attachments.each do |attach|
      attach.post = @post
    end
    
    #grabación de los attachments y las entries asociados
    @attachments.each do |attach|
      attach.save!
    end
            
    respond_to do |format| 
      format.html {
        if params[:post][:parent_id]
          redirect_to space_post_url(@space, @post.parent)
        else
          redirect_to space_post_url(@space, @post)
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
           
    respond_to do |format|
      format.html { 
        redirect_to space_post_path(@space,@post)  
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
      format.html { redirect_to space_posts_path(@container) }
      format.atom { head :ok }
      # FIXME: Check AtomPub, RFC 5023
#      format.send(mime_type) { head :ok }
      format.xml { head :ok }
    end
  end
   
  private
  
  def get_post 
    @post = Post.find(params[:id])
  end
end
