require 'openid'
require 'openid/extensions/sreg'

# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController

  # render new.rhtml
  def new
  end

  def create
    # Login/Password login
    if !params[:login].blank? && !params[:password].blank?
      authenticate :login_and_password, params[:login], params[:password]
    # OpenID login begining
    elsif !params[:openid_identifier].blank?
      begin
        openid_request = openid_consumer.begin params[:openid_identifier]
      rescue OpenID::OpenIDError => e
        flash[:error] = "Discovery failed for #{ params[:openid_identifier] }: #{ e }"
        render :action => "new"
        return
      end

      sreg_request = OpenID::SReg::Request.new
      # required fields
      sreg_request.request_fields(['nickname', 'email'], true)
      # optional fields
      # sreg_request.request_fields(['fullname'], false)

      #TODO: PAPE, OpenID Provider Authentication Policy
      # see: http://openid.net/specs/
      # papereq = OpenID::PAPE::Request.new
      # ...

      return_to = open_id_complete_url
      #FIXME: How do you refer to the root url??
      realm = (session_url).gsub('session', '')

      if openid_request.send_redirect?(realm, return_to)
        redirect_to openid_request.redirect_url(realm, return_to)
      else
        @form_text = openid_request.form_markup(realm, return_to, true, { 'id' => 'openid_form' })
        render :layout => nil
      end
      return
    # OpenID login completion
    elsif params[:open_id_complete]
      # Filter path parameters
      parameters = params.reject{ |k,v| request.path_parameters[k] }
      # Complete the OpenID verification process
      openid_response = openid_consumer.complete(parameters, return_to)

      case openid_response.status
      when OpenID::Consumer::SUCCESS
        flash[:notice] = "Verification of #{ openid_response.display_identifier } succeeded"
        uri = CMS::URI.find_or_create_by_uri(openid_response.display_identifier)
        unless authenticate(:openid, uri)
          # TODO if already authenticated, add URI to Agent.openid_ownings
          # else
          # We create new OpenidUser
          session[:openid_identifier] = openid_response.display_identifier
          sreg_response = OpenID::SReg::Response.from_success_response(openid_response)
          render_component :controller => "users",
                           :action => "create",
                           :params => { :openid_user => sreg_response.data }
          return
        end
      when OpenID::Consumer::FAILURE
        flash[:error] = openid_response.display_identifier ?
          "Verification of #{ openid_response.display_identifier } failed: #{ openid_response.message }" :
          "Verification failed: #{ openid_response.message }"
      when OpenID::Consumer::SETUP_NEEDED
        flash[:error] = "Immediate request failed - Setup Needed"
      when OpenID::Consumer::CANCEL
        flash[:notice] = "OpenID transaction cancelled"
      end
    end

    if authenticated?
      if params[:remember_me] == "1"
        self.current_agent.remember_me
        cookies[:auth_token] = { :value => self.current_agent.remember_token , :expires => self.current_agent.remember_token_expires_at }
      end
      redirect_back_or_default '/spaces/0'
      flash[:notice] = "Logged in successfully"
    else
      flash[:error] ||= "Wrong credentials"
      render :action => 'new'
    end
  end

  def destroy
    self.current_agent.forget_me if authenticated?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default('/spaces/0')
  end

  private

  # Try authentication in every Agent class
  def authenticate(method, *params)
    # There are many Agent classes to be authenticated, and authentication methods
    for klass in CMS.agent_classes
      if klass.agent_options[:authentication].include?(method)
        auth_agent ||= klass.send "authenticate_with_#{ method }", *params
      end
    end

    # Finter not activated and disabled agents
    if ! auth_agent.activated_at
      flash[:notice] = "Please confirm your registration"
    elsif auth_agent.disabled
      flash[:notice] = "Disabled user"
    else
      self.current_agent = auth_agent
      return auth_agent
    end if auth_agent
    nil
  end

  def openid_consumer
    @openid_consumer ||= OpenID::Consumer.new(session,
                                              CMS::OpenID::ActiveRecordStore.new)
  end

end
