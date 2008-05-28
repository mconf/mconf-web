
class HomeController < ApplicationController  
   include CMS::Controller::Base
  def index
  
    @cloud = Tag.cloud
    next_events

  end
  
  def next_events


    today = Date.today
    
   date1ok =  today.strftime("%Y%m%d")
   s_date = Ferret::Search::SortField.new(:start_dates, :type => :float)
   sort = Ferret::Search::Sort.new(s_date)
     @total, @events, @query = Event.date_search_five(date1ok,:lazy => [:name, :description, :tag_list, :start_dates],  :page => (params[:page]||1), :sort=> sort)          
   @pages = pages_for(@total)
    
    
  end
  end