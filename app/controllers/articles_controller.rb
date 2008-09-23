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
  before_filter :get_content, :except => [ :index, :new, :create, :search_articles ]
  #before_filter :is_public_space, :only=>[:index]
  before_filter :get_space
  #before_filter :get_space_from_entry, :only => [ :show, :edit, :update ]
  before_filter :get_cloud
  
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
                                                        :conditions => { :content_type => "XhtmlText" , :parent_id => nil },
                                                        :order => "updated_at DESC")
           if @space.id==1
            @entries = @public_entries.select {|e| e.parent_id == nil && e.content_type == 'XhtmlText'}.paginate(:page => params[:page], :per_page => number_pages)
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
            format.atom
            format.xml { render :xml => @entries.to_xml.gsub(/cms\/entry/, "entry") }
          end
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
    
    @last_attachment = params[:last_post]
    @content = Article.create(params[:content])
    if params[:entry][:parent_id]
      params[:entry][:public_read] = true
    end
    @entry = Entry.create(params[:entry].merge({ :agent => current_agent,
        :container => @container,
        :content => @content,
        :description => params[:content][:text]}))
    i=0;

   (@last_attachment.to_i).times  {
      if params[:"attachment#{i}"]!= nil && params[:"attachment#{i}"]!= {"uploaded_data"=>""} #if entry has attachments....
          @attachment_content = Attachment.create(params[:"attachment#{i}"]) 
          @attachment_entry = @entry.children.create({ :agent => current_agent,
          :container => @container,
          :content => @attachment_content, 
          :description => params[:content][:text],
          :title => params[:title],
          :parent_type => @entry.content,
          :public_read => params[:entry][:public_read]})
      end
      i += 1;}
    respond_to do |format| 
      format.html {
        if !@content.new_record? && @entry.save ####Siempre comprueba el entry padre  
          if params[:attachment0] != {"uploaded_data"=>""}    #####Si tiene attachment, comprueba si se han salvado bien
            if !@attachment_content.new_record? && @attachment_entry.save  
            else
            @attachment_content.destroy unless @attachment_content.new_record?
            @attachment_entry.destroy
            @collection_path = space_articles_path
            @title ||= "New #{ controller_name.singularize.humanize }".t
            end
          end
          @entry.tag_with(params[:tags]) if params[:tags]
          @entry.category_ids = params[:category_ids]
          flash[:valid] = "#{ @content.class.to_s.humanize } created".t
          if params[:entry][:parent_id] == nil
            redirect_to space_article_url(@space, @entry.content_id)
          else
            redirect_to space_article_url(@space, @entry.parent.content)
          end
          
        else
          @content.destroy unless @content.new_record?
          @collection_path = space_articles_path
          @title ||= "New #{ controller_name.singularize.humanize }".t
          if @container.class == Entry 
          
            @entry_ = @entry
            @entry = @container
            @errors = true
            render :template => "articles/show" , :object => {@errors, @entry_}
          else
          @errors = true
          @entry_= @entry
            render :template => "articles/new" , :object => {@entry_, @errors}
          end
        end
      }
      
      format.atom {
        if !@content.new_record? & @entry.save 
          headers["Location"] = formatted_article_url(@entry, :atom)
          headers["Content-type"] = 'application/atom+xml'
          render :partial => "articles/entry",
          :status => :created,
          :locals => { :entry => @entry,
            :content => @content },
          :layout => false
        else
          if @content.new_record?
            render :xml => @content.errors.to_xml, :status => :bad_request
          else
            @content.destroy unless @content.new_record?
            render :xml => @entry.errors.to_xml, :status => :bad_request
          end
        end
      }
    end
  end
  
  def new 
        session[:current_sub_tab] = "New article"
        @collection_path = space_articles_path
        @entry = Entry.new
        @entry.content = @content = instance_variable_set("@#{controller_name.singularize}", controller_name.classify.constantize.new)
        @title ||= "New #{ controller_name.singularize.humanize }".t
        render :template => "articles/new"
  end
  
     # Show this Entry
      #   GET /articles/:id
      def show
        @title ||= @entry.title
        @comment_children = @entry.children.select{|c| c.content.is_a? Article}
        @attachment_children = @entry.children.select{|c| c.content.is_a? Attachment}
        
        respond_to do |format|
          format.html
          format.xml { render :xml => @entry.to_xml(:include => [ :content ]) }
          format.atom { 
            headers["Content-type"] = 'application/atom+xml'
            render :partial => "articles/entry",
                               :locals => { :entry => @entry },
                               :layout => false
          }
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
        get_params_title_and_description(@entry)
        @attachment_children = @entry.children.select{|c| c.content.is_a? Attachment}
        params[:category_ids] = @entry.category_ids
    
        render :template => "articles/edit"
      end
  
  # Update this Entry metadata
      #   PUT /articles/:id
      def update       
       set_params_title_and_description(@entry.content) 
       
        # If the Content of this Entry hasn't attachment, update it here
        # If it has, update via media
        # 
        # TODO: find old content when only entry params are updated
        # Avoid the user changes container through params
        params[:entry][:container] = @entry.container
        #params[:entry][:agent]     = current_agent Problema.Con esto edito al usuario por eso lo cambio
        params[:entry][:agent] = @entry.agent
        params[:entry][:content]   = @content
   
   @last_attachment = params[:last_post]
   @attachment_children = @entry.children.select{|c| c.content.is_a? Attachment}
   @attachment_children.each{|children|
      if params[:"#{children.id}"] == "false"
        children.content.destroy
      end
   }
        respond_to do |format|
          format.html {
           i=0;
   (@last_attachment.to_i).times  {
      if params[:"attachment#{i}"]!= nil && params[:"attachment#{i}"]!= {"uploaded_data"=>""} #if entry has attachments....
          @attachment_content = Attachment.create(params[:"attachment#{i}"]) 
          @attachment_entry = @entry.children.create({ :agent => current_agent,
                  :container => @container,
                  :content => @attachment_content, 
                  :description => params[:content][:text],
                  :title => params[:title],
                  :parent_type => @attachment_content.type,
                  :public_read => params[:entry][:public_read]})
       end
       i += 1;}
                   
           #   @entry.update_attributes(params[:entry]) && @entry.update_attribute(:description , params[:content][:text]) && @attachment_entry.save && @content.update_attributes(:text => params[:content][:text])
          #    @entry.tag_with(params[:tags]) if params[:tags]
           #   @entry.category_ids = params[:category_ids]
           #   flash[:valid] = "#{ @content.class.to_s.humanize } updated".t 
            #  redirect_to space_article_path(@container,@entry.content)
            
         if !@content.new_record? &&  @entry.update_attributes(params[:entry]) && @entry.update_attribute(:description , params[:content][:text]) && @content.update_attributes(:text => params[:content][:text])
              @entry.tag_with(params[:tags]) if params[:tags]
              @entry.category_ids = params[:category_ids]
              flash[:valid] = "#{ @content.class.to_s.humanize } updated".t
              redirect_to space_article_path(@container,@entry.content)
            else
              render :template => "articles/edit" 
            end
         # else
            #the error here
             
        #end   
          }
    
          format.atom {
            if !@content.new_record? && @entry.update_attributes(params[:entry])
              head :ok
            else
              render :xml => [ @content.errors + @entry.errors ].to_xml,
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
  #he añadido aquí el get_entry pero no me gusta un pelo
  def get_entry 
         @article = Article.find(params[:id])
         @entry = @article.content_entries.first
     end

  #def get_space_from_entry
    #session[:current_tab] = "Posts" 
    #@space = @entry.container
  #end
  
end
