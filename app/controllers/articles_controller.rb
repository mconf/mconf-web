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
  
  before_filter :get_entry, :except => [ :index, :new, :create ]
  before_filter :get_public_entries, :only => [:index,:show]
  # Get Article in member actions
 # before_filter :get_content, :except => [ :index, :new, :create, :search_articles ]
  
  authorization_filter :article, :edit, :only=>[:edit,:update]
  
  set_params_from_atom :article, :only => [ :create, :update ]
  
  def index
     session[:current_tab] = "Posts"
     session[:current_sub_tab] = ""
        if @container
          if params[:per_page] != nil
            number_pages = params[:per_page]
          else
            number_pages = 10
          end

          @title ||= "#{ 'Entry'.t('Entries', 99) } - #{ @container.name }"
          # All the Entries this Agent can read in this Container
          @collection = @container.container_entries.find(:all,
                                                        :conditions => { :content_type => "Article" , :parent_id => nil },
                                                        :order => "updated_at DESC")
           if @space.id==1
            @entries = @public_entries.select {|e| e.parent_id == nil && e.content_type == 'Article'}.paginate(:page => params[:page], :per_page => number_pages)
            else
          # Paginate them
          @entries = @collection.paginate(:page => params[:page], :per_page => number_pages)
          @updated = @collection.blank? ? @container.updated_at : @collection.first.updated_at
          @collection_path = space_articles_path(@container)
        
            end
        else
          @title ||= 'Entry'.t('Entries', 99)
          @entries = Entry.paginate :all,
                                      :conditions => [ "public_read = ?", true ],
                                      :page =>  params[:page],
                                      :order => "updated_at DESC"
          @updated = @entries.blank? ? Time.now : @entries.first.updated_at
          @collection_path = entries_path
        end
        
        if params[:expanded] == "true"
          respond_to do |format|
            format.html {render :template => "articles/index2"}
            format.atom
            format.xml { render :xml => @entries.to_xml.gsub(/cms\/entry/, "entry") }
          end
        else
          respond_to do |format|
            format.html 
            format.atom {@entries = @container.container_entries.find(:all,
                                                        :conditions => { :content_type => "Article" },
                                                        :order => "updated_at DESC")}
            format.xml { render :xml => @entries.to_xml.gsub(/cms\/entry/, "entry") }
          end
        end
    end
    
  def create

    #creación del Artículo padre
    @article = Article.new(params[:article])
    if !@article.valid?
      respond_to do |format|
        format.html {   
      if  params[:comment] == nil #mira si es un comentario o no para hacer el render
          flash[:error] = "The content of the article can't be empty"  
          render :action => "new"    
          return
      else
          flash[:error] = "The comment is not valid" 
          render :action => "new"   
          return
          
      end   }
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
          @attachments << @attachment #almacena referencias de los Attachments nuevos que se están creando
      end
      i += 1;}
    
      #validamos todos los attachments
      @attachments.each do |attach|
        if !attach.valid?
          if params[:comment] == nil
          flash[:error] = "The attachment is not valid"  
          render :action => "new"  
          return
        else
          flash[:error] = "The attachment is not valid"  
          render :action => "new"   
          return
          end
        end
      end
         
  #Si los attachments y el artículo son válidos pasamos a crear las entradas y salvarlos.
    params[:entry] ||= HashWithIndifferentAccess.new
    @article.entry = Entry.new(params[:entry].merge({ :agent => current_agent, #entrada asociada al artículo
        :container => @container,
        :content => @article,
        :title => params[:article][:title],
        :description => params[:article][:text],
        }))
        
    @article.save! #salvamos el artículo y con ello su entrada asociada  
    @article.tag_with(params[:tags]) if params[:tags] #pone las tags a la entrada asociada al artículo
     #@article.category_ids = params[:category_ids]
     flash[:valid] = "Article created".t
 

    #creación de las entries con contenidos de attachment
   @attachments.each do |attach|
         attach.entry = Entry.new({ :agent => current_agent,
          :container => @container,
          :content => attach, 
          :title => params[:article][:title],
          :description => params[:article][:text],
          :parent_id => @article.entry.id})
   end 
   #grabación de los attachments y las entries asociados
        @attachments.each do |attach|
        attach.save!
        attach.tag_with(params[:tags]) if params[:tags]
      end
            
    respond_to do |format| 
      format.html {
    
          #if params[:entry][:parent_id] == nil 
          if params[:comment] == nil
            redirect_to space_article_url(@space, @article)
          else
            redirect_to space_article_url(@space, @article.entry.parent.content)
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
        @article.entry = Entry.new
        @title ||= "New #{ controller_name.singularize.humanize }".t

  end
  
     # Show this Entry
      #   GET /articles/:id
      def show
        @title ||= @article.title
        @comment_children = @article.entry.children.select{|c| c.content.is_a? Article}
        @attachment_children = @article.entry.children.select{|c| c.content.is_a? Attachment}
        
        respond_to do |format|
          format.html
          format.xml { render :xml => @entry.to_xml(:include => [ :content ]) }
          format.atom 
          format.json { render :json => @entry.to_json(:include => :content) }
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
        @attachment_children = @article.entry.children.select{|c| c.content.is_a? Attachment}

      end
  
  # Update this Entry metadata
      #   PUT /articles/:id
      def update       

        params[:entry][:container] = @space
        params[:entry][:agent]     = current_agent #Problema.Con esto edito al usuario por eso lo cambio
        #params[:entry][:agent] = @entry.agent
        params[:entry][:content]   = @article
            
        #actualizo los atributos del artículo
        @article.attributes = params[:article]
        if !@article.valid?
          respond_to do |format|
            format.html {          flash[:error] = "The content of the article can't be empty"  
          render :action => "edit"  }
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
          @attachments << @attachment
      end
      i += 1;}
    
       #valido los attachments para ver si el contendio es correcto
      @attachments.each do |attach|
        if !attach.valid?
          flash[:error] = "The attachment is not valid"  
          render :action => "edit"   
          return
        end
      end 
      
        #creo las entradas asociadas a los artículos 
        @article.entry.attributes = params[:entry].merge({ :agent => current_agent,
        :container => @container,
        :content => @article,
        :title => params[:article][:title],
        :description => params[:article][:text],
        })
        
        @article.save! #salva el artículo y su entrada asociada        
        @article.tag_with(params[:tags]) if params[:tags] #pone las tags a la entrada asociada al artículo
        flash[:valid] = "Article updated".t
           
        #Creación de las entries asociadas a los attachments
        @attachments.each do |attach|
            attach.entry = Entry.new({ :agent => current_agent,
            :container => @container,
            :content => attach, 
            :description => params[:article][:text],
            :parent_id => @article.entry.id})
        end      
        #Salvamos los attachments y sus entries asociadas
        @attachments.each do |attach|
          attach.save!
          attach.tag_with(params[:tags]) if params[:tags]
       end 
            
  
         #elimina los attachments quitados al pulsar el botón remove
        @last_attachment = params[:last_post]
        @attachment_children = @article.entry.children.select{|c| c.content.is_a? Attachment}
        @attachment_children.each {|children|
        if params[:"#{children.id}"] == "false"
          children.content.destroy
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
  def get_entry 
         @article = Article.find(params[:id])
         @entry = @article.entry
     end

  #def get_space_from_entry
    #session[:current_tab] = "Posts" 
    #@space = @entry.container
  #end
  
end
