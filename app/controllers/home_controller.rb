
class HomeController < ApplicationController  
   include CMS::Controller::Base
   before_filter :get_container
   
  def index
  
    @cloud = Tag.cloud
   next_events

  end
  

  

  end