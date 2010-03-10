class OpenIdOwningsController < ApplicationController
  include ActionController::Sessions::Openid

  authentication_filter

  def create
    session[:openid_return_to] = request.referer || url_for(:action => 'index', :only_path => false)
    create_session_with_openid

    unless performed?
      redirect_to request.referer || { :action => 'index' }
    end
  end

  def destroy
    open_id_owning.destroy

    redirect_to request.referer || { :action => 'index' }
  end

  private

  def open_id_owning
    @open_id_owning ||= current_agent.openid_ownings.find(params[:id])
  end
end
