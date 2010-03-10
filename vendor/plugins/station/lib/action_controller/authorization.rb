module ActionController #:nodoc:
  # Authorization module provides your Controllers and Views with methods and filters
  # to control which actions Agents can perform
  #
  # This module uses Agent identification support from ActionController::Authentication
  #
  # == Authorization Filters
  # You can define authorization filters in the following way:
  #   authorization_filter permission, auth_object, filter_options
  #
  # permission:: Argument defining the Permission, examples: :read, :destroy, [ :update, :task ]
  # auth_object:: a Symbol representing a controller's instance variable name or method. This variable or method gives the authorization object, an instance that will be queried for checking authorization. This is actually achived calling <tt>auth_object.authorize?(permission, :to => current_agent)</tt>. See ActiveRecord::Authorization to define authorization security policies.
  # fiter_options:: Available options are:
  #  if:: A Proc proc{ |controller| ... } or Symbol to be executed as condition of the filter
  #   
  #  The rest of options are passed to before_filter. See Rails before_filter documentation
  #   
  #
  # === Examples
  #
  #  class AttachmentsController < ActionController::Base
  #    authorization_filter [ :read, :attachment ], :space, { :only => [ :index ] }
  #    authorization_filter [ :create, :attachment ], :space, { :only => [ :new, :create ] }
  #
  #    authorization_filter :read, :attachment, :only => [ :show ]
  #    authorization_filter :update, :attachment, :only => [ :edit, :update ]
  #    authorization_filter :delete, :attachment, :only => [ :destroy ]
  #
  #  end
  #
  module Authorization
    # Inclusion hook to add ActionController::Authentication
    def self.included(base) #:nodoc:
      base.send :include, ActionController::Authentication unless base.ancestors.include?(ActionController::Authentication)

      base.helper_method :authorize?, :authorized?
      # Deprecated
      base.helper_method :authorizes?

      class << base
        # Calls not_authorized unless stage allows current_agent to perform actions
        def authorization_filter(permission, auth_object, options = {})
          if_condition = options.delete(:if)
          filter_condition = case if_condition
                             when Proc
                               if_condition
                             when Symbol
                               proc{ |controller| controller.send(if_condition) }
                             else
                               proc{ |controller| true }
                             end

          before_filter options do |controller|
            if filter_condition.call(controller)
              controller.not_authorized unless controller.authorized?(permission, auth_object)
            end
          end
        end
      end
    end

    # Object that resolves default authorization queries. Defaults to current_site
    def default_authorization_instance
      current_site
    end

    # Calls authorize? on default_authorization_instance with current_agent
    #
    # permission defaults to controller's action_name
    def authorize?(permission = nil)
      permission ||= action_name.to_sym

      default_authorization_instance.authorize?(permission, :to => current_agent)
    end

    # If user is not authenticated, return not_authenticated to allow identification. 
    # Else, set HTTP Forbidden (403) response.
    def not_authorized
      return not_authenticated unless authenticated?

      respond_to do |format|
        format.all do
          render :text => 'Forbidden',
                 :status => 403
        end

        format.html do
          render(:file => "#{RAILS_ROOT}/public/403.html", 
                 :status => 403)
        end
      end
    end

    def authorized?(permission = nil, auth_object_name = nil) #:nodoc:
      permission ||= action_name
      auth_object = case auth_object_name
                   when Symbol
                     begin
                      self.instance_variable_get("@#{ auth_object_name }")
                     rescue NameError
                     end || send(auth_object_name)
                   when NilClass
                     default_authorization_instance
                   else
                     auth_object_name
                   end

      auth_object.authorize?(permission, :to => current_agent)
    end
  end
end
