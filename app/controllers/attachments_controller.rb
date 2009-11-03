class AttachmentsController < ApplicationController
  include ActionController::StationResources
  
  # Authentication Filter
  before_filter :authentication_required, :except => [ :index, :show ]

  # Needs a space always
  before_filter :space!
  
  before_filter :has_repository?
  
  # Get Attachment in member actions
  #before_filter :attachment, :except => [ :index, :new, :create ]
  
  authorization_filter [ :read, :content ],   :space, :only => [ :index ]
  authorization_filter [ :create, :content ], :space, :only => [ :new, :create ]
  authorization_filter :read,   :attachment, :only => [ :show ]
  authorization_filter :update, :attachment, :only => [ :edit, :update ]
  authorization_filter :delete, :attachment, :only => [ :delete ]
  
  def index
    attachments
end

def new
   @attachment ||= Attachment.new 
   @attachment.post ||= Post.new 
end

def edit
  @attachment = Attachment.find(params[:id])
end

   
   
    #  def index_with_vcc
    #    index_without_vcc do
    #      get_sorted_objects(params)
    #    end
    #  end
    # 
    #  alias_method_chain :index, :vcc
    
    #  def show
    #      @image = Attachment.find(params[:id])
    #
    #    respond_to do |format|
    #      format.html {
    #      if @image
    #      send_data @image.current_data, :filename => @image.filename,
    #                                             :type => @image.content_type,
    #                                             :disposition => 'inline'
    #      end
    #      } # show.html.erb
    #      format.xml  { render :xml => @attachment }
    #    end
    #  end
    

  private

  # Redirect to spaces/:permalink/attachments if new attachment is created
  def after_create_with_success
    redirect_to [ space, Attachment.new ]
  end
  def after_update_with_success
    redirect_to [ space, Attachment.new ]
  end
  
  def after_update_with_errors
    flash[:error] = @attachment.errors.to_xml
    attachments
    render :action => :index
  end
  
  def attachments
    @tags = params[:tags].present? ? params[:tags].split(",").map{|t| Tag.in_container(@space).find(t.to_i)} : Array.new
    
    @attachments = Attachment.roots.in_container(@space).sorted(params[:order],params[:direction])
    
    #ask tapi to do it better
    @tags.each do |t|
      @attachments = @attachments.select{|a| a.tags.include?(t)}
    end
    
    @attachments.sort!{|x,y| x.author.name <=> y.author.name } if params[:order] == 'author' && params[:direction] == 'desc'
    @attachments.sort!{|x,y| y.author.name <=> x.author.name } if params[:order] == 'author' && params[:direction] == 'asc'
    @attachments.sort!{|x,y| x.content_type.split("/").last <=> y.content_type.split("/").last } if params[:order] == 'type' && params[:direction] == 'desc'
    @attachments.sort!{|x,y| y.content_type.split("/").last <=> x.content_type.split("/").last } if params[:order] == 'type' && params[:direction] == 'asc'
  end

  def has_repository?   
    if  !space.repository?
      
      respond_to do |type| 
        type.html { render :template => "errors/error_403", :layout => 'application', :status => 403 } 
        type.all  { render :nothing => true, :status => 403 } 
      end
    end
    true
  end
end