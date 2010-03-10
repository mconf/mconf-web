module ActionController #:nodoc:
  # Controller methods and default filters for Agents Controllers
  module Agents
    class << self
      def included(base) #:nodoc:
        base.send :include, ActionController::Station unless base.ancestors.include?(ActionController::Station)
        base.send :include, ActionController::Authentication unless base.ancestors.include?(ActionController::Authentication)
        if base.model_class.agent_options[:activation] &&
           ! base.ancestors.include?(ActionController::Agents::Activation)
          base.send :include, ActionController::Agents::Activation
        end
        if base.model_class.agent_options[:authentication].include?(:login_and_password) &&
           ! base.ancestors.include?(ActionController::Agents::PasswordReset)
          base.send :include, ActionController::Agents::PasswordReset
        end
      end
    end

    def index
      # AtomPub feeds are ordered by Entry#updated_at
      # TODO: move this to ActionController::Base#params_parser
      if request.format == Mime::ATOM
        params[:order], params[:direction] = "updated_at", "DESC"
      end

      @agents = model_class.roots.in(path_container).column_sort(params[:order], params[:direction]).paginate(:page => params[:page])
      instance_variable_set "@#{ model_class.to_s.tableize }", @agents

      respond_to do |format|
        format.html # index.html.erb
        format.js
        format.xml  { render :xml => @agents }
        format.atom
      end
    end

    # Show agent
    #
    # Responds to Atom Service format, returning the Containers this Agent can post to
    def show
      respond_to do |format|
        format.html {
          if agent.agent_options[:openid_server]
            headers['X-XRDS-Location'] = polymorphic_url(agent, :format => :xrds)
          end
        }
        format.atomsvc
        format.xrds
      end
    end
  
    # Render a form for creating a new Agent
    def new
      @agent = model_class.new
      instance_variable_set "@#{ model_class.to_s.underscore }", @agent
      @title = authenticated? ?
        t(:new, :scope => model_class.to_s.underscore) :
        t(:join_to_site, :site => Site.current.name)
    end

    # Create new Agent instance
    def create
      @agent = model_class.new(params[:agent])

      unless authenticated?
        cookies.delete :auth_token
        @agent.openid_identifier = session[:openid_identifier]
      end

      @agent.save!

      if authenticated?
        redirect_to polymorphic_path(model_class.new)
        flash[:success] = t(:created, :scope => @agent.class.to_s.underscore)
      else
        self.current_agent = @agent
        redirect_to @agent
        flash[:success] = t(:account_created)
      end

      if model_class.agent_options[:activation]
        flash[:success] << '<br />'
        flash[:success] << ( @agent.active? ?
          t(:activation_email_sent, :scope => @agent.class.to_s.underscore) :
          t(:should_check_email_to_activate_account))
      end
    rescue ::ActiveRecord::RecordInvalid
      render :action => 'new'
    end

    def destroy
      agent.destroy
      flash[:success] = t(:deleted, :scope => agent.class.to_s.underscore)
      redirect_to polymorphic_path(model_class.new)
    end
  
    protected
  
    # Get Agent filter
    # Gets Agent instance by id or login
    #
    # Example GET /users/1 or GET /users/quentin
    def agent
      @agent ||= ( params[:id].match(/^\d+$/) ? model_class.find(params[:id]) : model_class.find_by_login(params[:id]) )
      raise ActiveRecord::RecordNotFound, "Agent not found" unless @agent
      instance_variable_set "@#{ model_class.to_s.underscore }", @agent
    end

    private

    def after_activate_path
      root_path
    end

    def after_not_activate_path
      root_path
    end
  end
end
