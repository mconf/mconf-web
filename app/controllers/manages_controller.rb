class ManagesController < ApplicationController
  authorization_filter :manage, :site  
  
  def show
    @users=User.find(:all)
    @spaces=Space.find(:all)
  end
  
end