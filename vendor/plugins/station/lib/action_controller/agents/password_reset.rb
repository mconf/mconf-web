module ActionController #:nodoc:
  module Agents
    # Password recovery methods for Agent Controllers
    module PasswordReset
      def lost_password
        if params[:email]
          @agent = model_class.find_by_email(params[:email])
          unless @agent
            flash[:error] = t(:could_not_find_anybody_with_that_email_address)
            return
          end
    
          @agent.lost_password
          flash[:notice] = t(:password_reset_link_sent_to_email_address)
          redirect_to root_path
        end
      end
    
      # Resets Agent password via email
      def reset_password
        @agent = model_class.find_by_reset_password_code(params[:reset_password_code])
        raise unless @agent
        return if params[:password].blank?
        
        @agent.update_attributes(:password => params[:password], 
                                 :password_confirmation => params[:password_confirmation])
        if @agent.valid?
          @agent.reset_password
          current_agent = @agent
          flash[:success] = t(:password_has_been_reset)
          redirect_to("/")
        end
    
        rescue
          flash[:error] = t(:invalid_password_reset_code)
          redirect_to("/")
      end
    end
  end
end
