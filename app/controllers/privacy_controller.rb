class PrivacyController < ApplicationController
  def index
    render :layout => "application_without_sidebar_center_blue"
  end
end
