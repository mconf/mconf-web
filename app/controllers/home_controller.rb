
class HomeController < ApplicationController  
   include CMS::Controller::Base
   before_filter :get_space
    before_filter :get_cloud
  def index
    session[:current_tab] = "Home"
    
    next_events
  end
  
  def index2
    redirect_to "/spaces/0"
  end
 

  end