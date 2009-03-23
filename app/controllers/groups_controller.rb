class GroupsController < ApplicationController
 
  before_filter :space
  
  def create
    @group = @space.groups.build(params[:group])
    
    if @group.save
      respond_to do |format|
      format.html {
      flash[:success] = "The group " + @group.name + " has been successfully created"
        redirect_to space_users_path(@space, :list_by => 'groups')
      }
      end
    else
      flash[:error] = "The group is not valid"
      redirect_to space_users_path(@space)
    end
  end
end