class UiController < ApplicationController
  layout 'ui/layouts/application'
 
  def home
    render :layout=> "/ui/layouts/home_application"
 end
end