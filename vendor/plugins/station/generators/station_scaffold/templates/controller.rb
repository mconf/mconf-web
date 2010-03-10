class <%= controller_class_name %>Controller < ApplicationController
  # Include CRUD methods.
  #
  # You can overwritte them if you need it, but consider adding 
  # the functionality in the Model
  include ActionController::StationResources

end
