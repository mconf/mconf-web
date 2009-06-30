class ManageController < ApplicationController
  authorization_filter :manage, :site  
  
  def users
    @users=User.find(:all,:order => "login")
  end

  def spaces
    @spaces=Space.find(:all,:order => "name")
  end
  
  def spam
    @spam_events= Event.find(:all, :conditions => {:spam => true})
    @spam_posts = Post.find(:all, :conditions => {:spam => true})
  end
  
end