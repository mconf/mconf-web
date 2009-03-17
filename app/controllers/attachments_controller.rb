class AttachmentsController < ApplicationController
  include ActionController::MoveResources
  
  # Authentication Filter
  before_filter :authentication_required, :except => [ :index, :show ]
  
  # Needs a Container when posting a new Attachment
  before_filter :container!, :only => [ :new, :create ]
      
  # Get Attachment in member actions
  before_filter :resource, :except => [ :index, :new, :create ]
  
  #authorization_filter :space, [ :read,   :Content ], :only => [ :index ]
  #authorization_filter :space, [ :create, :Content ], :only => [ :new, :create ]
  #authorization_filter :attachment, :read,   :only => [ :show ]
  #authorization_filter :attachment, :update, :only => [ :edit, :update ]
  #authorization_filter :attachment, :delete, :only => [ :delete ]
  
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


