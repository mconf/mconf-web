begin
  require 'openid'
  require 'openid/extensions/sreg'
rescue MissingSourceFile
  raise "Station: You need 'ruby-openid' gem for OpenID authentication support"
end

module ActionController #:nodoc:
  module Sessions
    # OpenID sessions management
    module OpenID
      # Create new Session using OpenID
      def create_session_with_openid(params = self.params, options = {})
        options[:return_to]   ||= open_id_complete_url
        options[:realm]       ||= "http://#{ request.host_with_port }/"
        options[:sreg_fields] ||= ['nickname', 'email']

        if params[:openid_identifier].present?
          begin
            openid_request = openid_consumer.begin params[:openid_identifier]
          rescue ::OpenID::OpenIDError => e
            flash[:error] = t('openid.client.discovery_failed', :id => params[:openid_identifier], :error => e)
            return
          end

          sreg_request = ::OpenID::SReg::Request.new
          # required fields
          sreg_request.request_fields(options[:sreg_fields], true)
          # optional fields
          # sreg_request.request_fields(['fullname'], false)

          #TODO: PAPE, OpenID Provider Authentication Policy
          # see: http://openid.net/specs/
          # papereq = ::OpenID::PAPE::Request.new
          # ...

          if openid_request.send_redirect?(options[:realm], open_id_complete_url)
            redirect_to openid_request.redirect_url(options[:realm], open_id_complete_url)
          else
            #FIXME: create 
            @form_text = openid_request.form_markup(options[:realm], open_id_complete_url, true, { 'id' => 'openid_form' })
            render :partial => 'sessions/openid_form', :layout => nil
          end
        # OpenID login completion
        elsif params[:open_id_complete]
          # Filter path parameters
          parameters = params.reject{ |k,v| request.path_parameters[k] }
          # Complete the OpenID verification process
          openid_response = openid_consumer.complete(parameters, open_id_complete_url)

          case openid_response.status
          when ::OpenID::Consumer::SUCCESS
            flash[:success] = t('openid.client.verification_succeeded_with_id', :id => openid_response.display_identifier)
            uri = Uri.find_or_create_by_uri(openid_response.display_identifier)

            # If already authenticated, add URI to Agent.openid_ownings
            if authenticated? && ! current_agent.openid_uris.include?(uri)
              current_agent.openid_uris << uri
              flash[:success] = t('openid.client.id_attached_to_account', :id => uri)
              
              if session[:openid_return_to].present?
                redirect_to session.delete(:openid_return_to)
                return
              else
                return current_agent
              end
            end

            ActiveRecord::Agent.authentication_classes(:openid).each do |klass|
              self.current_agent = 
                klass.authenticate_with_openid(uri)
              break if authenticated?
            end

            if authenticated?
              # redirect_back_or_default after_create_path
              flash[:success] = t(:logged_in_successfully)
              return current_agent
            else
              # We create new local Agent with OpenID data
              session[:openid_identifier] = openid_response.display_identifier
              sreg_response = ::OpenID::SReg::Response.from_success_response(openid_response)
              redirect_to :controller => ActiveRecord::Agent.authentication_classes(:openid).first.to_s.tableize,
                          :action => "new",
                          :params => {
                            ActiveRecord::Agent.authentication_classes(:openid).first.to_s.tableize => sreg_response.data
                          }
            end
          when ::OpenID::Consumer::FAILURE
            flash[:error] = openid_response.display_identifier ?
              t('openid.client.verification_failed_with_id', :id => openid_response.display_identifier, :message => openid_response.message) :
              t('openid.client.verification_failed', :message => openid_response.message)
            return
          when ::OpenID::Consumer::SETUP_NEEDED
            flash[:error] = t('openid.client.immediate_request_failed')
            return
          when ::OpenID::Consumer::CANCEL
            flash[:error] = t('openid.client.transaction_cancelled')
            return
          end
        end
      end

      private

      def openid_consumer #:nodoc:
        @openid_consumer ||= ::OpenID::Consumer.new(session,
                                                    OpenIdActiveRecordStore.new)
      end
    end
    Openid = OpenID
  end
end
