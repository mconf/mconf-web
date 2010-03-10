begin
  require 'casclient'
  require 'casclient/frameworks/rails/filter'
rescue MissingSourceFile
  raise "Station: You need 'rubycas-client' gem for CAS authentication support"
end

module ActionController #:nodoc:
  module Sessions
    # Central Authentication Service (CAS) session support
    module CAS
      # Initialize CAS session
      def new_session_with_cas
        initialize_cas_filter

        cas_filter_result = ::CASClient::Frameworks::Rails::Filter.filter(self)

        # CAS Filter just returns true if the Agent is already authenticated
        if cas_filter_result && ! performed?
          redirect_to :action => 'create',
                      :ticket => session[:cas_last_valid_ticket].ticket
        end
      end

      # Create session using CAS
      def create_session_with_cas
        return nil unless params[:ticket]
        initialize_cas_filter

        if ::CASClient::Frameworks::Rails::Filter.filter(self)
          ActiveRecord::Agent.authentication_classes(:cas).each do |klass|
            self.current_agent = 
              klass.authenticate_with_cas(session[:cas_user])

            break if authenticated?
          end

          if authenticated?
            flash[:success] = t(:logged_in_successfully)
            return self.current_agent
          else
            redirect_to :controller => ActiveRecord::Agent.authentication_classes(:cas).first.to_s.tableize,
                        :action => "new",
                        :params => { 
                          ActiveRecord::Agent.authentication_classes(:cas).first.to_s.underscore.to_sym => {
                            :login => session[:cas_user]
                          }
                        }
          end
        end
      end

      # Logout on CAS Server
      def destroy_session_with_cas
        initialize_cas_filter

        redirect_to ::CASClient::Frameworks::Rails::Filter.client.logout_url(nil, request.referer)
      end

      private

      def initialize_cas_filter #:nodoc:
        return if ::CASClient::Frameworks::Rails::Filter.config

        begin
          klass = ActiveRecord::Agent.authentication_classes(:cas).first

          options = klass.agent_options[:cas_filter].clone
          options[:service_url] ||= session_url

          ::CASClient::Frameworks::Rails::Filter.configure(options)
        rescue
          raise "You must set :cas_filter configuration options in #{ klass }#acts_as_agent"
        end
      end
    end
    Cas = CAS
  end
end
