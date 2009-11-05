class AttachmentsController < ApplicationController
  include ActionController::StationResources
  
  # Authentication Filter
  before_filter :authentication_required, :except => [ :index, :show ]

  # Needs a space always
  before_filter :space!
  
  # Get Attachment in member actions
  #before_filter :attachment, :except => [ :index, :new, :create ]
  
  authorization_filter [ :read, :content ],   :space, :only => [ :index ]
  authorization_filter [ :create, :content ], :space, :only => [ :new, :create ]
  authorization_filter :read,   :attachment, :only => [ :show ]
  authorization_filter :update, :attachment, :only => [ :edit, :update ]
  authorization_filter :delete, :attachment, :only => [ :delete ]
  
  def index
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
    
    if params[:doc_info].present?
      @attachment=Attachment.find(params[:doc_info])
      @attachment.revert_to(params[:version].to_i) if params[:version].present?
    end

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
end
