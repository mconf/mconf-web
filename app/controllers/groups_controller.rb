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
      redirect_to space_users_path(@space, :list_by => 'groups')
    end
  end
  
  def edit
    redirect_to space_users_path(@space, :list_by => 'groups', :edit_group => params[:id])
  end
  
  def update
    @group = @space.groups.find(params[:id])
    if @group.update_attributes(params[:group])
      respond_to do |format|
      format.html {
      flash[:success] = "The group " + @group.name + " has been successfully updated"
        redirect_to space_users_path(@space, :list_by => 'groups')
      }
      end
    else
      flash[:error] = "The group is not valid"
      redirect_to space_users_path(@space, :list_by => 'groups')
    end
  end
  
  def destroy
    group = @space.groups.find(params[:id])
    if group.destroy
    respond_to do |format|
      format.html {
        flash[:success] = "The group has been successfully deleted"
        redirect_to space_users_path(@space, :list_by => 'groups')
      }
      end
    else
      flash[:error] = "Error deleting the group"
      redirect_to space_users_path(@space, :list_by => 'groups')
    end
  end
end