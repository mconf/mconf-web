class PController < ApplicationController
  
  def index
    @init_url = home_url;
    @current_site_jab_port = 5222;
    @current_site_jab_domain = current_site.presence_domain;
    @current_site_jab_httpbind = "/http-bind/";
    
    render :layout => false
  end
  
end
