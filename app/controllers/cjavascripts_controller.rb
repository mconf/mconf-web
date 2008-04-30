class CjavascriptsController < ApplicationController
  
  def add_user
    @space = Space.find(params[:container_id])
  end
  
  def create_group
    @container = Space.find(params[:container_id])
    if params[:role_id]
       @role = CMS::Role.find(params[:role_id])
    else
      @role = CMS::Role.new
    end
   
  end
  
end
