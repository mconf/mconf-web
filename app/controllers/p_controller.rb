class PController < ApplicationController
  
  before_filter :authentication_required
  
  def index
    @init_url = home_url;
    @current_site_jab_port = 5222;
    @current_site_jab_domain = "chotis.dit.upm.es";
    @current_site_jab_httpbind = "/http-bind/";
    
    render :layout => false
  end
  
end
