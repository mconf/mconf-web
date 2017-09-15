# Deals with the automatic redirections when the user e.g. signs in
# and adds helper methods related to redirects in general.
module Mconf::RedirectControllerModule

  # Where to redirect to after a sign in with devise.
  # Overrides devise's method.
  def after_sign_in_path_for(resource)
    if !params["return_to"].blank? && is_return_to_valid?(params["return_to"])
      previous = params["return_to"]
    elsif !external_or_blank_referer?
      previous = user_return_to
    end

    return_to = previous || my_home_path

    clear_stored_location
    return_to
  end

  protected

  # Checks if it's ok to redirect the user to the path in `request`. Considers
  # the URL and the type of the request (e.g. xhr requests are not redirectable to).
  def request_is_redirectable?(request)
    # Some xhr request need to be stored
    xhr_paths = ["/manage/users", "/manage/spaces"]

    # This will filter xhr requests that are not for html pages. Requests for html pages
    # via ajax can change the url and we might want to store them.
    valid_format = (request.format == "text/html" || request.content_type == "text/html") && ( !request.xhr? || xhr_paths.include?(request.path) )

    path_is_redirectable?(request.path) && valid_format
  end

  # Checks if it's ok to redirect the user to `path`. Considers only the URL, not
  # the type of the request or anything else.
  def path_is_redirectable?(path)
    # Paths to which users should never be redirected back to.
    ignored_paths = [ "/login", "/users/login", "/users", "/logout", "/guest/logout",
                      "/register", "/users/registration",
                      "/users/registration/signup", "/users/registration/cancel",
                      "/users/password", "/users/password/new",
                      "/users/confirmation/new", "/users/confirmation",
                      "/users/shibboleth", "/users/shibboleth/info", "/users/shibboleth/associate", "/secure",
                      "/users/pending", "/feedback/webconf", "/language/.*",
                      "/users/auth/.*",
                      "/#{Rails.application.config.conf_scope}/rooms/.*/join", "/#{Rails.application.config.conf_scope}/rooms/.*/end"]
    ignored_paths.select{ |ignored| path.match("^"+ignored+"$") }.empty?
  end

  # If the `path` passed as a parameter to redirect the user to it is valid or not.
  # It's not valid for paths we can't redirect to or external links.
  def is_return_to_valid?(path)
    return true if path.blank?
    path_is_redirectable?(path) && !external_or_blank_url?(path)
  end

  # Store last url for post-login redirect to whatever the user last visited.
  # From: https://github.com/plataformatec/devise/wiki/How-To:-Redirect-back-to-current-page-after-sign-in,-sign-out,-sign-up,-update
  def store_location
    if request_is_redirectable?(request) #&& !external_or_blank_url?(request.url)

      # can't use user_return_to because it is overridden
      # before actions and views are executed.
      session[:previous_user_return_to] = session[:user_return_to]

      # used by devise
      session[:user_return_to] = request.fullpath
      # session[:last_request_time] = Time.now.utc.to_i
    end
  end

  # Removes the stored location used to redirect post-login.
  def clear_stored_location
    session[:user_return_to] = nil
  end

  # Path to where the user would be redirect back to
  def user_return_to
    session[:user_return_to]
  end

  # Previous path to where the user would be redirect back to
  def previous_user_return_to
    session[:previous_user_return_to]
  end

  # Whether the user came from "nowhere" (no referer) or from an external URL.
  # Because we don't to redirect the user somewhere if he came from outside
  # or typed something in the address bar
  def external_or_blank_referer?
    external_or_blank_url?(request.referer)
  end

  def external_or_blank_url?(url)
    return true if url.blank?

    parsed = URI.parse(url.to_s)

    # no host on it means it's only a path, so it's not external
    return false if !parsed.try(:host)

    site_scheme = current_site.ssl? ? 'https' : 'http'
    parsed = URI.parse("#{site_scheme}://#{current_site.domain}")
    site = "#{parsed.try(:scheme)}://#{parsed.try(:host)}:#{parsed.try(:port)}"

    parsed = URI.parse(url.to_s)
    from_url = "#{parsed.try(:scheme)}://#{parsed.try(:host)}:#{parsed.try(:port)}"

    from_url != site
  end

end
