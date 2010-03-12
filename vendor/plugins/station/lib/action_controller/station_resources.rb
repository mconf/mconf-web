module ActionController #:nodoc:
  # Controller methods for Resources
  #
  module StationResources
    class ContainerError < ::StandardError  #:nodoc:
    end

    class << self
      def included(base) #:nodoc:
        base.send :include, ActionController::Station unless base.ancestors.include?(ActionController::Station)
        base.class_eval do                                     # class ArticlesController
          alias_method controller_name, :resources             #   alias_method :articles, :resources
          helper_method controller_name                        #   helper_method :articles
          alias_method controller_name.singularize, :resource  #   alias_method :article, :resource
          helper_method controller_name.singularize            #   helper_method :article
        end                                                    # end

        base.send :rescue_from, ContainerError, :with => :container_error

        base.send :include, ActionController::Authorization unless base.ancestors.include?(ActionController::Authorization)
      end
    end

    # List Resources
    #
    # When the Resource is a Content, uses in(container) named_scope
    # When it's a Sortable, uses column_sort named_scope
    #
    # It also paginates using great Mislav will_paginate plugin
    #
    #   GET /resources
    #   GET /resources.xml
    #   GET /resources.atom
    #
    #   GET /:container_type/:container_id/contents
    #   GET /:container_type/:container_id/contents.xml
    #   GET /:container_type/:container_id/contents.atom
    def index
      # AtomPub feeds are ordered by updated_at
      # TODO: move this to ActionController::Base#params_parser
      if request.format == Mime::ATOM
        params[:order], params[:direction] = "updated_at", "DESC"
      end

      @conditions ||= nil

      resources

      if block_given?
        yield
      else
        respond_to do |format|
          format.html # index.html.erb
          format.js
          format.xml  { render :xml => @resources }
          format.atom
        end
      end
    end

    # Show this Content
    #
    #   GET /resources/1
    #   GET /resources/1.xml
    def show
      if params[:version] && resource.respond_to?(:versions)
        resource.revert_to(params[:version].to_i)
      end

      if params[:thumbnail] && resource.respond_to?(:thumbnails)
        @resource = resource.thumbnails.find_by_thumbnail(params[:thumbnail]) 
      end

      instance_variable_set "@#{ model_class.to_s.underscore }", resource

      respond_to do |format|
        format.all {
          send_data resource.__send__(:current_data),
                    :filename => resource.filename,
                    :type => resource.content_type,
                    :disposition => resource.class.resource_options[:disposition].to_s
        } if resource.class.resource_options[:has_media]

        format.html # show.html.erb
        format.js
        format.xml  { render :xml => @resource }
        format.atom
  
        # Add Resource format Mime Type for resource with Attachments
        format.send(resource.mime_type.to_sym.to_s) {
          send_data resource.__send__(:current_data),
                    :filename => resource.filename,
                    :type => resource.content_type,
                    :disposition => resource.class.resource_options[:disposition].to_s
        } if resource.mime_type

      end
    end

    # Render form for posting new Resource
    #
    #   GET /resources/new
    #   GET /resources/new.xml
    #   GET /:container_type/:container_id/contents/new
    def new
      resource

      respond_to do |format|
        format.html # new.html.erb
        format.js
        format.xml  { render :xml => @resource }
      end
    end

    # GET /resources/1/edit
    def edit
      resource
    end

    # Create new Resource
    #
    #   POST /resources
    #   POST /resources.xml
    #   POST /:container_type/:container_id/contents
    def create
      # Fill params when POSTing raw data
      set_params_from_raw_post

      resource_params = params[model_class.to_s.underscore.to_sym]
      resource_class =
        model_class.resource_options[:delegate_content_types] &&
        resource_params[:media] && resource_params[:media].present? &&
        ActiveRecord::Resource.class_supporting(resource_params[:media].content_type) ||
        model_class

      @resource = resource_class.new(resource_params)
      instance_variable_set "@#{ model_class.to_s.underscore }", @resource

      @resource.author = current_agent if @resource.respond_to?(:author=)
      @resource.container = path_container  if @resource.respond_to?(:container=)

      respond_to do |format|
        if @resource.save
          format.html { 
            flash[:success] = t(:created, :scope => @resource.class.to_s.underscore)
            after_create_with_success
          }
          format.js
          format.xml  { 
            render :xml      => @resource, 
                   :status   => :created, 
                   :location => @resource 
          }
          format.atom {
            render :action => 'show',
                   :status => :created,
                   :location => polymorphic_url(@resource, :format => :atom)
          }
        else
          format.html { 
            after_create_with_errors
          }
          format.js
          format.xml  { render :xml => @resource.errors, :status => :unprocessable_entity }
          format.atom { render :xml => @resource.errors.to_xml, :status => :bad_request }
        end
      end
    end

    # Update Resource
    #
    # PUT /resources/1
    # PUT /resources/1.xml
    def update
      # Fill params when POSTing raw data
      set_params_from_raw_post

      resource.attributes = params[model_class.to_s.underscore.to_sym]
      resource.author = current_agent if resource.respond_to?(:author=) && resource.changed?

      respond_to do |format| 
        #FIXME: DRY
        format.all {
          if resource.save
            head :ok
          else
            render :xml => @resource.errors.to_xml, :status => :not_acceptable
          end
        }

        format.html {
          if resource.save
            flash[:success] = t(:updated, :scope => @resource.class.to_s.underscore)
            after_update_with_success
          else
            after_update_with_errors
          end
        }
        format.js {
          resource.save
        }
        format.atom {
          if resource.save
            head :ok
          else
            render :xml => @resource.errors.to_xml, :status => :not_acceptable
          end
        }

        format.send(resource.format) {
          if resource.save
            head :ok
          else
            render :xml => @resource.errors.to_xml, :status => :not_acceptable
          end
        } if resource.format
      end
    end

    # DELETE /resources/1
    # DELETE /resources/1.xml
    def destroy
      respond_to do |format|
        if resource.destroy
          format.html {
            flash[:success] = t(:deleted, :scope => @resource.class.to_s.underscore)
            after_destroy_with_success
          }
          format.js
          format.xml  { head :ok }
          format.atom { head :ok }
        else
          format.html {
            flash[:error] = t(:not_deleted, :scope => resource.class.to_s.underscore)
            flash[:error] << resource.errors.to_xml
            after_destroy_with_errors
          }
          format.js
          format.xml  { render :xml => @resource.errors.to_xml }
          format.atom { render :xml => @resource.errors.to_xml }
        end
      end
    end

    protected

    # Finds the current Resource using model_class
    #
    # If params[:id] isn't present, build a new Resource
    def resource
      @resource ||= if params[:id].present?
                      instance_variable_set("@#{ model_class.to_s.underscore }", 
                        model_class.in(path_container).find_with_param(params[:id]) ||
                        raise(ActiveRecord::RecordNotFound, "Resource not found"))
                    else
                      r = model_class.new(params[model_class.to_s.underscore.to_sym])
                      r.container = path_container if r.respond_to?(:container=) && path_container.present?
                      instance_variable_set("@#{ model_class.to_s.underscore }", r)
                    end
    end

    def resources
      @resources ||= instance_variable_set "@#{ model_class.to_s.tableize }",
                       model_class.roots.in(path_container).column_sort(params[:order], params[:direction]).paginate(:page => params[:page], :conditions => @conditions)
    end

    # Search in the resource's containers and in the path for current Container.
    #
    # We start with the following assumptions:
    # * A Container have a unique branch of nested containers in the containers tree
    # * If we find containers of the same type in both branches (resource containers
    # and path), they must be the same. If they aren't we assume a routing error (409 Conflict).
    #
    # Options:
    # type:: the class of the container
    def current_container(options = {})
      find_current_container(options)
    end

    private

    def find_current_container(options) #:nodoc:
      rc = resource_container(options)

      path_options = options.dup
      path_options[:ancestors] = path_options.delete(:path_ancestors)
      pc = path_container(path_options)

      if rc.present? && pc.present? &&
           rc != pc 
        raise ContainerError
      end

      rc || pc
    end

    # Gets a container from the resource containers
    def resource_container(options = {}) #:nodoc:
      return nil unless resource.present?

      @resource_container_candidates ||=
        Array( resource.class.acts_as?(:container) ?
                 resource.container_and_ancestors :
                 resource.class.acts_as?(:content) ?
                   resource.container.try(:container_and_ancestors) :
                   nil ).compact

      candidates = filter_type(@resource_container_candidates, options[:type])

      candidates.first
    end

    # Redirect here after create if everythig went well
    def after_create_with_success
      redirect_to @resource
    end

    # Redirect here after create if there were errors
    def after_create_with_errors
      render :action => "new"
    end

    # Redirect here after update if everythig went well
    def after_update_with_success
      redirect_to @resource
    end

    # Redirect here after update if there were errors
    def after_update_with_errors
      render :action => "edit"
    end

    # Redirect here after destroy if everythig went well
    def after_destroy_with_success
      redirection = (
        request.referer.present? &&
        !(request.referer =~ /#{ polymorphic_path(resource) }/) ?
          request.referer :
          [ path_container, model_class.new ] )
      redirect_to redirection
    end

    # Redirect here after destroy if there were errors
    def after_destroy_with_errors
      redirect_to(request.referer || [ path_container, model_class.new ])
    end

    def container_error(e) #:nodoc:
      render :text => 'Container route conflicts with resource container',
             :status => 409
    end
  end
end
