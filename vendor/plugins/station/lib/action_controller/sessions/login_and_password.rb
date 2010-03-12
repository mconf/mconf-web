module ActionController #:nodoc:
  module Sessions
    # Methods for Sessions based on LoginAndPassword Authentication 
    module LoginAndPassword
      # Init Session using LoginAndPassword Authentication
      def create_session_with_login_and_password(params = self.params)
        return if params[:login].blank? || params[:password].blank?

        agent = nil

        ActiveRecord::Agent.authentication_classes(:login_and_password).each do |klass|
          agent = klass.authenticate_with_login_and_password(params[:login], params[:password])
          break if agent
        end

        if agent
          if agent.agent_options[:activation] && ! agent.activated_at
            flash[:notice] = t(:please_activate_account)
          elsif agent.respond_to?(:disabled) && agent.disabled
            flash[:error] = t(:disabled, :scope => agent.class.to_s.tableize)
          else
            flash[:success] = t(:logged_in_successfully)
            return self.current_agent = agent
          end
        else
          flash[:error] ||= t(:invalid_credentials)
        end
        return
      end
    end
  end
end
