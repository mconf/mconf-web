module Mconf::ErrorRenderingModule

  # TODO: refactor so that the 'unless all_resquests_local' is in
  # render_error_page and things get a little more DRY
  def render_error_page number
    # If we're here because of an error in an after_fiter this will trigger a DoubleRender error.
    # To prevent it we'll just clear the response_body before continuing
    self.response_body = nil
    render :template => "/errors/error_#{number}", :status => number, :layout => "error"
  end

  # Add some stack trace info to production log
  def log_stack_trace exception
    Rails.logger.info "#{exception.class.name} (#{exception.message}):"
    st = "  " + exception.backtrace.first(15).join("\n  ")
    Rails.logger.info st
  end

  def render_404(exception)
    @route ||= request.path
    unless Rails.application.config.consider_all_requests_local
      @exception = exception
      render_error_page 404
      log_stack_trace exception
    else
      raise exception
    end
  end

  def render_500(exception)
    unless Rails.application.config.consider_all_requests_local
      @exception = exception
      ExceptionNotifier.notify_exception exception
      render_error_page 500
      log_stack_trace exception
    else
      raise exception
    end
  end

  def render_403(exception)
    unless Rails.application.config.consider_all_requests_local
      @exception = exception
      render_error_page 403
    else
      raise exception
    end
  end

  def render_400(exception)
    unless Rails.application.config.consider_all_requests_local
      self.response_body = nil
      render(nothing: true, status: 400)
    else
      raise exception
    end
  end

end
