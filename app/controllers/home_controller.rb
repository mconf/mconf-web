
class HomeController < ApplicationController  
   include CMS::Controller::Base
  def index
    next_events

  end
  
  def next_events

    
    today = Date.today
    
   date1ok =  today.strftime("%Y%m%d")
     @total, @events, @query = Event.date_search_five(date1ok,:lazy => [:name, :description, :tag_list, :start_dates],  :page => (params[:page]||1))          
   @pages = pages_for(@total)
    
    
  end
  end