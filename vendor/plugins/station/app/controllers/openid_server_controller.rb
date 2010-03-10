begin
  require 'openid'
  require 'openid/extensions/sreg'
rescue MissingSourceFile
  raise "Station: You need 'ruby-openid' gem for OpenID server support"
end

class OpenidServerController < ApplicationController
  include OpenID::Server
  layout nil

  # TODO antiphishing
  before_filter :authentication_required, :except => :index

  # Relaying Parties are affected by "protect_from_forgery" in ApplicationController 
  # when POSTing associations
  skip_before_filter :verify_authenticity_token, :only => :index
  
  def index
    begin
      openid_request = openid_server.decode_request(params)
    rescue ProtocolError => e
      # invalid OpenID request
      render :text => e.to_s, :status => :bad_request
      return
    end

    # no openid.mode was given
    unless openid_request
      render :text => t('openid.server.endpoint'), :status => :bad_request
      return 
    end

    if openid_request.kind_of?(CheckIDRequest)
      unless authenticated?
        render :partial => "anti_phishing"
        return
      end

      if openid_request.id_select
        @identity = current_agent.openid_uris.first
      else
        # TODO: claimed_id
        @identity = Uri.find_by_uri(openid_request.identity)
        unless @identity && current_agent.openid_uris.include?(@identity)
          render :text => t('openid.server.invalid_uri', :uri => openid_request.identity), :status => :forbidden
          return
        end
      end

      @trust_root = openid_request.trust_root

      if openid_request.immediate
        openid_response = openid_request.answer(false)

      elsif current_agent.openid_trust_uris.include?(Uri.find_or_create_by_uri(@trust_root))
         openid_response = openid_request.answer(true)
        
        # TODO add the sreg response if requested
        #self.add_sreg(openid_request, openid_response)
       
      else
        # OpenID Simple Registration Extension fields
        #if sreg_request = OpenID::SReg::Request.from_openid_request(openid_request)
        #  @required = sreg_request.required
        #  @optional = sreg_request.optional
        #  #TODO policy_url
        #end

        session[:openid_request] = openid_request
        render :partial => 'new', :layout => 'application'
        return
      end

    else
      openid_response = openid_server.handle_request(openid_request)
    end
  
    self.render_response(openid_response)
  end

  def create
    # There is not previous OpenID request
    openid_request = session[:openid_request]
    unless openid_request
      render :text => t(:bad_request), :status => :bad_request
      return
    end

    # Decision is blank or invalid
    unless %w( once trust cancel ).include?(params[:decision])
      flash[:info] = t('openid.server.decision')
      render :partial => "new", :layout => "application"
      return
    end

    session[:openid_request] = nil

    if params[:decision] == "cancel"
      redirect_to openid_request.cancel_url
      return
    end

    openid_response = openid_request.answer(true)

    # OpenID SReg Extension
    #sreg_request = ::OpenID::SReg::Request.from_openid_request(openid_request)
    #sreg_response = ::OpenID::SReg::Response.extract_response(sreg_request, params[:sreg]) if sreg_request && params[:sreg]
    #openid_response.add_extension(sreg_response) if sreg_response

    if params[:decision] == "trust"
      uri = Uri.find_or_create_by_uri(openid_request.trust_root)
      current_user.openid_trust_uris << uri

      #TODO: save SReg data
    end

    return self.render_response(openid_response)
  end

  protected

  def openid_server
    @openid_server ||= Server.new(OpenIdActiveRecordStore.new, 
                                  url_for(:action => 'index', :only_path => false))
  end

  def render_response(openid_response)    
    #XXX: this is form ruby-openid/examples/rails_server
    # What do we need if for??? It isn't used!
    if openid_response.needs_signing
      signed_response = openid_server.signatory.sign(openid_response)
    end

    web_response = openid_server.encode_response(openid_response)

    case web_response.code
    when HTTP_OK
      render :text => web_response.body, :status => :ok
    when HTTP_REDIRECT
      redirect_to web_response.headers['location']
    else
      render :text => web_response.body, :status => :bad_request
    end   
  end
end
