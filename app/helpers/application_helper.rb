# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'version'
require './lib/mconf/modules'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  include Mconf::Modules # so the views can access it too

  def copyable_field(id, content, opt={})
    opt[:label] ||= id
    content_tag :div, :class => 'input-append copyable-field' do
      concat content_tag(:label, opt[:label]) if opt.has_key?(:label)
      concat text_field_tag(id, content, opt.except(:label))
      concat content_tag(:a, '', :class => "icon-awesome icon-paste add-on", :href => "#")
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

  def page_title title, opt ={}
    inside_resource = " #{opt[:in]} &#149;" if opt[:in].present?
    content_for :title do
      "#{title} &#149;#{inside_resource} #{current_site.name}".html_safe
    end
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

  # Renders the partial 'layout/page_title'
  # useful to simplify the calls from the views
  # Now also sets the html title tag for the page
  # Ex:
  #   <%= render_page_title('users', 'logos/user.png', { :transparent => true }) %>
  def render_page_title(title, logo=nil, options={})
    page_title title
    block_to_partial('layouts/page_title', options.merge(:page_title => title, :logo => logo))
  end

  # Renders the partial 'layout/sidebar_content_block'
  # If options[:active], will set a css style to emphasize the block
  # Ex:
  #   <%= render_sidebar_content_block('users') do %>
  #     any content
  #   <% end %>
  def render_sidebar_content_block(id=nil, options={}, &block)
    options[:active] ||= false
    block_to_partial('layouts/sidebar_content_block', options.merge(:id => id), &block)
  end

  # Checks if the current page is the user's home page
  def at_home?
    params[:controller] == 'my' && params[:action] == 'home'
  end

  # Returns the url prefix used to identify a webconf room
  # e.g. 'https://server.org/webconf/'
  def webconf_url_prefix
    # note: '/webconf' is defined in routes.rb
    "#{Site.current.domain_with_protocol}/webconf/"
  end

  # Returns the url prefix used to identify a webconf room
  # e.g. '/webconf/'
  def webconf_path_prefix
    # note: '/webconf' is defined in routes.rb
    "/webconf/"
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

  #
  # TODO: All the code below should be reviewed
  #

  # Initialize an object for a form with suitable params
  # TODO: not really needed, can be replaced by @space.post.build, for example
  def prepare_for_form(obj, options = {})
    case obj
    when Post
      obj.space = @space if obj.space.blank?
    when Attachment
      obj.space = @space if obj.space.blank?
    else
      raise "Unknown object #{ obj.class }"
    end

    options.each_pair do |method, value|  # Set additional attributes like:
      obj.__send__ "#{ method }=", value         # post.event = @event
    end

    obj
  end

  # Every time a form needs to point a role as default (User, admin, guest, ...)
  def default_role
    Role.default_role
  end

  # First 'size' characters of a text
  def first_words(text, size)
    truncate(text, :length => size)
  end

  private

  # Based on http://www.igvita.com/2007/03/15/block-helpers-and-dry-views-in-rails/
  # There's a better solution at http://pathfindersoftware.com/2008/07/pretty-blocks-in-rails-views/
  # But render(:layout => 'something') with a block is not working (rails 3.1.3, jan/12)
  def block_to_partial(partial_name, options={}, &block)
    options.merge!(:body => capture(&block)) if block_given?
    render(:partial => partial_name, :locals => options)
  end
end
