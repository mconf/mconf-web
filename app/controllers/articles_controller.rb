class ArticlesController < ApplicationController
  # Include some methods and set some default filters. 
  # See documentation: ActionController::Contents#included
  include ActionController::Contents
  
  set_params_from_atom :article, :only => [ :create, :update ]
  
  # Articles list may belong to a container
  # /articles
  # /:container_type/:container_id/articles
  before_filter :get_container, :only => [ :index,:search_articles  ]
  
  # Needs a Container when posting a new Article
  before_filter :container!, :only => [ :new, :create ]
  
  before_filter :get_article, :except => [ :index, :new, :create ]
  before_filter :get_public_entries, :only => [:index,:show]
  

  authorization_filter :space, [ :read,   :Content ], :only => [ :index ]
  authorization_filter :space, [ :create, :Content ], :only => [ :new, :create ]
  authorization_filter :article, :read,   :only => [ :show ]
  authorization_filter :article, :update, :only => [ :edit, :update ]
  authorization_filter :article, :delete, :only => [ :destroy ]

  def index

     session[:current_tab] = "News"
     session[:current_sub_tab] = ""
          @title ||= "News - #{ @space.name }"
          if !params[:per_page]
            params[:per_page] = 10
          end
   #Estas 3 líneas lo que hacen es meter en @articles lo que hay en la linea 2 si el espacio es el público y si no, mete lo de la línea 3
             @articles =(@space.id == 1 ?
             Article.in_container(nil).find(:all,:conditions => {"entries.parent_id" => nil, "entries.public_read" => true}, :order => "updated_at DESC").paginate(:page => params[:page], :per_page => params[:per_page]):       
             Article.in_container(@space).find(:all, :conditions => {"entries.parent_id" => nil}, :order => "updated_at DESC").paginate(:page => params[:page], :per_page => params[:per_page]))       
             
                    
        if params[:expanded] == "true"
          respond_to do |format|
            format.html {render :template => "articles/index2"}
            format.atom
            format.xml { render :xml => @articles }
          end
        else
          respond_to do |format|
            format.html 
            format.atom {@entries = @container.container_entries.find(:all,
                                                        :conditions => { :content_type => "Article" },
                                                        :order => "updated_at DESC")}
            format.xml { render :xml => @articles }
          end
        end
    end
    
  def create
    #creación del Artículo padre
    @article = Article.new(params[:article])
    @article.author = current_agent
    # Para comentarios desde el espacio Public
    @article.container = params[:article][:parent_id] ?
                         Entry.find(params[:article][:parent_id]).container :
                         @container
    
    if !@article.valid?
      respond_to do |format|
        format.html {   
          if  params[:article][:parent_id] #mira si es un comentario o no para hacer el render
            flash[:error] = "The comment is not valid" 
            render :action => "new"
          else
            flash[:error] = "The content of the article can't be empty"  
            render :action => "new"                
          end
        }
        format.xml { render :xml => @article.errors, :status => :unprocessable_entity }
        format.atom {render :xml => @article.errors.to_xml, :status => :bad_request}
      end
      return
    end  
    
    #Creación de los Attachments
    i=0;
    @attachments = []
    @last_attachment = params[:last_post] #miro el número de entradas de attachments que se han generado
    (@last_attachment.to_i).times  {
      if params[:"attachment#{i}"]!= nil && params[:"attachment#{i}"]!= {"uploaded_data"=>""} #if entry has attachments....
          @attachment = Attachment.new(params[:"attachment#{i}"])
          @attachment.author = current_agent
          @attachment.container = @article.container
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
      

    @article.save! #salvamos el artículo y con ello su entrada asociada  
    @article.tag_with(params[:tags]) if params[:tags] #pone las tags a la entrada asociada al artículo
    flash[:valid] = "Article created"
 

    #asignacion de los padres del attachment al articulo
    @attachments.each do |attach|
      attach.parent_id = @article.entry.id
    end
    
    #grabación de los attachments y las entries asociados
    @attachments.each do |attach|
      attach.save!
      attach.tag_with(params[:tags]) if params[:tags]
    end
            
    respond_to do |format| 
      format.html {
        if params[:article][:parent_id]
          redirect_to space_article_url(@space, @article.entry.parent.content)
        else
          redirect_to space_article_url(@space, @article)
        end
      }
      format.atom { 
        headers["Location"] = formatted_space_article_url(@space, @article, :atom )
        @entry = @article.entry
        render :action => :show,
               :status => :created
      }
    end
  end
  
  def new 
    session[:current_sub_tab] = "New article"
    @article = Article.new
    @title ||= "New Article"
  end
  
  # Show this Entry
  #   GET /articles/:id
  def show
    session[:current_tab] = "News"
    @title ||= @article.title
    @comment_children = @article.entry.children.select{|c| c.content.is_a? Article}
    @attachment_children = @article.entry.children.select{|c| c.content.is_a? Attachment}
    
    respond_to do |format|
      format.html
      format.xml { render :xml => @article.to_xml(:include => [ :content ]) }
      format.atom 
      format.json { render :json => @article.to_json(:include => :content) }
    end
  end
    
  # Delete this Entry
  #   DELETE /spaces/:id/articles/:id --> :method => delete
  def destroy
   #destroy de content of the entry. Then its container(entry) is destroyed automatic.
   @article.destroy 
    respond_to do |format|
      format.html { redirect_to space_articles_path(@container) }
      format.atom { head :ok }
      # FIXME: Check AtomPub, RFC 5023
#      format.send(mime_type) { head :ok }
      format.xml { head :ok }
    end
  end
  
  # Renders form for editing this Entry metadata
  #   GET /articles/:id/edit
  def edit
    @attachment_children = @article.attachments
  end
  
  # Update this Entry metadata
  #   PUT /articles/:id
  def update       
    #actualizo los atributos del artículo
    @article.attributes = params[:article]
    #@article.author = current_agent #Problema.Con esto edito al usuario por eso lo cambio
    

    if !@article.valid?
      respond_to do |format|
        format.html {
          flash[:error] = "The content of the article can't be empty"  
          render :action => "edit"
        }
        format.atom { render :xml => @article.errors.to_xml, :status => :not_acceptable }
      end
      return
    end  
        
    #creo los attachments que ha subido el usuario
    i=0;
    @attachments = []
    @last_attachment = params[:last_post] #miro el número de entradas de attachments que se han generado
    (@last_attachment.to_i).times  {
      if params[:"attachment#{i}"]!= nil && params[:"attachment#{i}"]!= {"uploaded_data"=>""} #if entry has attachments....
        @attachment = Attachment.new(params[:"attachment#{i}"]) 
        @attachment.author = current_agent
        @attachment.container = @article.container
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
      
        
    @article.save! #salva el artículo y su entrada asociada        
    @article.tag_with(params[:tags]) if params[:tags] #pone las tags a la entrada asociada al artículo
    flash[:valid] = "Article updated"
           
    #Creación de las entries asociadas a los attachments
    @attachments.each do |attach|
      attach.parent_id = @article.entry.id
    end 
        
    #Salvamos los attachments y sus entries asociadas
    @attachments.each do |attach|
      attach.save!
      attach.tag_with(params[:tags]) if params[:tags]
    end 
            
  
    #elimina los attachments quitados al pulsar el botón remove
    @last_attachment = params[:last_post]
    @attachment_children = @article.attachments
    @attachment_children.each {|children|
      if params[:"#{children.id}"] == "false"
        children.content.destroy
      else 
        children.content.save
      end
    }
            
    respond_to do |format|
      format.html { 
        redirect_to space_article_path(@space,@article)  
      }
      format.atom { head :ok }
    end
  end
    
  private
  
  def get_space_from_container
    session[:current_tab] = "Posts" 
    @space = @container
  end
  #he añadido aquí el get_entry pero no me gusta un pelo
  def get_article 
    @article = Article.find(params[:id])
    @entry = @article.entry
  end
end
