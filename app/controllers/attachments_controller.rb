class AttachmentsController < ApplicationController
  include ActionController::StationResources
  
  # Authentication Filter
  before_filter :authentication_required, :except => [ :index, :show ]
  
  # Needs a space always
  before_filter :space!
      
  # Get Attachment in member actions
  before_filter :attachment, :except => [ :index, :new, :create ]
  
  authorization_filter [ :read, :content ],   :space, :only => [ :index ]
  authorization_filter [ :create, :content ], :space, :only => [ :new, :create ]
  authorization_filter :read,   :attachment, :only => [ :show ]
  authorization_filter :update, :attachment, :only => [ :edit, :update ]
  authorization_filter :delete, :attachment, :only => [ :delete ]
  
  def index
    @attachments = Attachment.parent_scoped.in_container(@space).sorted(params[:order],params[:direction])
    @attachments.sort!{|x,y| x.author.name <=> y.author.name } if params[:order] == 'author' && params[:direction] == 'desc'
    @attachments.sort!{|x,y| y.author.name <=> x.author.name } if params[:order] == 'author' && params[:direction] == 'asc'
    @attachments.sort!{|x,y| x.content_type.split("/").last <=> y.content_type.split("/").last } if params[:order] == 'type' && params[:direction] == 'desc'
    @attachments.sort!{|x,y| y.content_type.split("/").last <=> x.content_type.split("/").last } if params[:order] == 'type' && params[:direction] == 'asc'
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
  
  def create
    #debugger
  end
  
  
  
end


