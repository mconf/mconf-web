class ManageController < ApplicationController
  authorization_filter :manage, :site  
  
  def users
    @users=User.find_with_disabled(:all,:order => "login")
    @site_roles = Site.roles
  end

  def spaces
    @spaces=Space.find_with_disabled(:all,:order => "name")
  end
  
  def spam
    @spam_events= Event.find(:all, :conditions => {:spam => true})
    @spam_posts = Post.find(:all, :conditions => {:spam => true})
  end
  
end