module ActionController #:nodoc:
  module Agents
    # Activation methods for Agent Controllers
    module Activation
      # Activate Agent from email
      def activate
        self.current_agent = params[:activation_code].blank? ? Anonymous.current : model_class.find_by_activation_code(params[:activation_code])
        if authenticated? && current_agent.respond_to?("active?") && !current_agent.active?
          current_agent.activate
          flash[:success] = t(:account_activated)
          redirect_back_or_default(after_activate_path)
        else
          redirect_back_or_default(after_not_activate_path)
        end
      end
    end
  end
end
