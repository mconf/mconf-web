# coding: utf-8
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'version'
require './lib/mconf/modules'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # so the views can access it too
  include Mconf::Modules
  include Mconf::GuestUserModule

  def clipboard_copy_field(id, content, opt={})
    content_tag :div, :class => 'form-group copyable-field' do
      content_tag :div, :class => 'input-group' do
        input_class = "#{opt[:class]} form-control"
        concat content_tag(:label, opt[:label]) if opt.has_key?(:label)
        concat text_field_tag(id, content, opt.except(:label).merge(class: input_class))
        btn = content_tag :a, '', :class => 'input-group-addon btn clipboard-copy', 'data-clipboard-target': "##{id}" do
          concat content_tag(:i, '', :class => "icon fa fa-paste")
        end
        concat btn
      end
    end
  end

  def application_version
    Mconf::VERSION
  end

  def application_revision
    Mconf.application_revision
  end

  def github_link_to_revision(revision)
    "https://github.com/mconf/mconf-web/commit/#{revision}"
  end

  def page_title(title, opt ={})
    inside_resource = " #{opt[:in]} &#149;" if opt[:in].present?
    content_for :title do
      "#{title} &#149;#{inside_resource} #{current_site.name}".html_safe
    end
  end

  def default_separator(no_space=false)
    s  = "&#149;"
    s += " " unless no_space
    s.html_safe
  end

  # Ex: asset_exists?('posts/edit', 'css')
  def asset_exists?(asset_name, default_ext)
    !Mconf::Application.assets.find_asset(asset_name + '.' + default_ext).nil?
  end

  # Includes javascripts for the current controller
  # Example: 'assets/events.js'
  def javascript_include_tag_for_controller
    ctl = controller_name_for_view
    if asset_exists?(ctl, "js")
      javascript_include_tag(ctl)
    end
  end

  # Includes stylesheets for the current controller
  # Example: 'assets/events.css'
  def stylesheet_link_tag_for_controller(options={})
    ctl = controller_name_for_view
    if asset_exists?(ctl, "css")
      stylesheet_link_tag(ctl, options)
    end
  end

  # Returns the name of the current controller to be used in view
  # (for js and css names). Used to convert names with slashes
  # such as 'devise/sessions'.
  def controller_name_for_view
    params[:controller].parameterize
  end

  # Returns the name of the layout in use
  def layout_name
    layout = controller.send(:_layout)

    # depending on how the layout is specified in the controller, it can
    # be a string or an object
    if layout.is_a?(String)
      layout
    else
      File.basename(layout.identifier).gsub(/\..*/, '')
    end
  end

  # Checks if the current page is the user's home page
  def at_home?
    params[:controller] == 'my' && params[:action] == 'home'
  end

  # Returns the url prefix used to identify a webconf room
  # e.g. 'https://server.org/webconf/'
  def webconf_url_prefix
    path = webconf_path_prefix
    path = '/' + path unless path.match(/^\//)
    "#{Site.current.domain_with_protocol}#{path}"
  end

  # Returns the url prefix used to identify a webconf room
  # e.g. '/webconf/'
  def webconf_path_prefix
    "#{Rails.application.config.conf_scope_rooms}/"
  end

  def options_for_tooltip(title, options={})
     options.merge!(:title => title,
                    :class => "tooltipped " + (options[:class] || ""),
                    :"data-placement" => options[:"data-placement"] || "top")
  end

  def user_signed_in_via_federation?
    shib = Mconf::Shibboleth.new(session)
    user_signed_in? && shib.signed_in?
  end

  def user_signed_in_via_ldap?
    ldap = Mconf::LDAP.new(session)
    user_signed_in? && ldap.signed_in?
  end

  # Returns a list of locales available in the application.
  def available_locales(all = false)
    if all
      Rails.application.config.i18n.available_locales
    else
      Site.current.visible_locales
    end
  end

  # Includes the "*" to denote that a field is required in a form. Useful when we can't use
  # the standard methods from simple_form for some reason.
  def form_required_label
    content_tag :abbr, "*", :title => I18n.t('_other.form.required')
  end

  # Retrieves max upload size from website or uses a default value
  def max_upload_size
    current_site.max_upload_size
  end

  # Returns an array with all image extensions supported by the application
  def supported_image_formats
    ['.jpg', '.jpeg', '.png']
  end

  # Includes elements in the page to disable the autocomplete of an input
  # In some browsers, such as Firefox, setting the attribute 'autocomplete=false' in
  # the input is not enough to disable its autocomplete, usually for username and
  # password inputs, so we have to do this workaround.
  def disable_autocomplete_for(name, type='text')
    attrs = {
      type: type,
      name: name,
      disabled: true,
      class: 'input-disable-autocomplete disabled',
      style: 'display:none;'
    }
    content_tag :input, nil, attrs
  end

  # Returns the previous path (the referer), if it exists and is a 'redirectable to'
  # path. Otherwise returns the fallback.
  def previous_path_or(fallback)
    session[:previous_user_return_to] || fallback
  end

  def captcha_tags(opts={})
    if current_site.captcha_enabled?
      content_tag :div, class: 'captcha' do
        params = { public_key: current_site.recaptcha_public_key, hl: I18n.locale }.merge(opts)
        recaptcha_tags params
      end
    end
  end

  # Stores the current tab in the menu in the administration pages of a space
  def bbb_server_admin_menu_at(tab)
    @bbb_server_admin_menu_tab = tab
  end

  # Selects the tab if it is the current tab in the administration menu of a tabs
  def bbb_server_admin_menu_select_if(tab, options={})
    old_class = options[:class] || ''
    @bbb_server_admin_menu_tab == tab ?
      options.update({ :class => "#{old_class} active" }) :
      options
  end

  # Sets the default value for a local variable in a view in case this variable is not set yet.
  # Preserves false and nil values set in the variable.
  # Example:
  #   show_authors = set_default(local_assigns, "show_authors", true)
  # TODO: find a way to access `local_assigns` here without passing in as a param.
  def set_default(local_assigns, var_name, value)
    if local_assigns.has_key?(var_name.to_sym)
      local_assigns[var_name.to_sym]
    else
      value
    end
  end

  # First 'size' characters of a text
  def first_words(text, size)
    truncate(text, length: size)
  end

  def locale_for_datetime_picker
    case I18n.locale.to_s
    when /^pt/
      'pt-BR'
    when /^es/
      'es'
    else
      I18n.locale.to_s
    end
  end

  # This is a helper to add an element with a tooltip. Useful mostly for disabled elements, that
  # cannot have tooltips on their own so need a wrapper with it.
  def with_tooltip(title, &block)
    content = capture(&block)
    content_tag(:div, content, class: 'with-tooltip tooltipped', title: title)
  end

  def sidenav_visible?
    # TODO: TEMPORARY
    # user_signed_in?
    false
  end

  # Stores the current tab in the sessions for spaces
  def sessions_menu_at(tab)
    @sessions_menu_tab = tab
  end

  # Selects the tab if it is the current tab in the menu for sessions
  def sessions_menu_select_if(tab, options={})
    old_class = options[:class] || ''
    @sessions_menu_tab == tab ?
      options.update({ :class => "#{old_class} active" }) :
      options
  end

  # Returns whether the selected menu is `tab`
  def sessions_menu_is(tab)
    @sessions_menu_tab == tab
  end
end
