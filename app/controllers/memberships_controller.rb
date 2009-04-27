class MembershipsController < ApplicationController
  before_filter :membership, :only => [:destroy]
  
  def create
    
    group = Group.find(params[:group_id])
    @membership = group.memberships.build(params[:membership])
    
    if @success = @membership.save
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js
      end  
    end
  end
  
  def destroy
    if @success = @membership.destroy
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js
      end  
    end
    
  end
  
  private
  
  def membership
    @membership = Membership.find(params[:id])  
  end
end