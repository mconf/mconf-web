
class HomeController < ApplicationController  

  def index
    session[:current_tab] = "Home"
    
    next_events
  end
  
  def index2
    redirect_to "/spaces/0"
  end
 

  end
