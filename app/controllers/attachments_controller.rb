class AttachmentsController < ApplicationController
  include ActionController::MoveResources
  
  # Authentication Filter
  before_filter :authentication_required, :except => [ :index, :show ]
  
  # Needs a Container when posting a new Attachment
  before_filter :space!, :only => [ :new, :create ]
      
  # Get Attachment in member actions
  before_filter :attachment, :except => [ :index, :new, :create ]
  
  authorization_filter [ :read, :content ],   :space, :only => [ :index ]
  authorization_filter [ :create, :content ], :space, :only => [ :new, :create ]
  authorization_filter :read,   :attachment, :only => [ :show ]
  authorization_filter :update, :attachment, :only => [ :edit, :update ]
  authorization_filter :delete, :attachment, :only => [ :delete ]
  
  def show
      @image = Attachment.find(params[:id])

    respond_to do |format|
      format.html {
      if @image
      send_data @image.current_data, :filename => @image.filename,
                                             :type => @image.content_type,
                                             :disposition => 'inline'
      end
      } # show.html.erb
      format.xml  { render :xml => @attachment }
    end
  end
  
  
  
end


