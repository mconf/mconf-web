class AboutController < ApplicationController
  def terms_cafe
    render :layout => "application_without_sidebar_center_blue"
  end
  def service_description
    render :layout => "application_without_sidebar_center_blue"
  end
end
