class AttachmentsController < ApplicationController
  # Include some methods and filters.
  include ActionController::Contents
  
  # Authentication Filter
  before_filter :authentication_required, :except => [ :index, :show ]
  
  # Needs a Container when posting a new Attachment
  before_filter :container!, :only => [ :new, :create ]
      
  # Get Attachment in member actions
  before_filter :get_content, :except => [ :index, :new, :create ]
  
  authorization_filter :space, [ :read,   :Content ], :only => [ :index ]
  authorization_filter :space, [ :create, :Content ], :only => [ :new, :create ]
  authorization_filter :attachment, :read,   :only => [ :show ]
  authorization_filter :attachment, :update, :only => [ :edit, :update ]
  authorization_filter :attachment, :delete, :only => [ :delete ]
end


