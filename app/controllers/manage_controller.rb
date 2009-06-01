class ManageController < ApplicationController
  authorization_filter :manage, :site  
  
  def users
    @users=User.find(:all,:order => "login")
  end

  def spaces
    @spaces=Space.find(:all,:order => "name")
  end
  
end