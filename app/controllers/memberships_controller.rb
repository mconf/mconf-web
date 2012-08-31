# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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
   group.regenerate_lists
  end
  
  def destroy
    group = Group.find(params[:group_id])
    if @success = @membership.destroy
      respond_to do |format|
        format.js
      end
    else
      respond_to do |format|
        format.js
      end  
    end    
    group.regenerate_lists
  end
  
  private
  
  def membership
    @membership = Membership.find(params[:id])  
  end
end