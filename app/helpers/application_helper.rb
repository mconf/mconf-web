require 'version'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # Clippy from https://github.com/lackac/clippy
  #
  # Generates clippy embed code with the given options. From the options one of
  # <tt>:text</tt>, <tt>:id</tt>, or <tt>:call</tt> has to be provided.
  #
  # === Supported options
  # [:text]
  #   Text to be copied to the clipboard.
  # [:id]
  #   Id of a DOM element from which the text should be taken. If it is a form
  #   element the <tt>value</tt> attribute, otherwise the <tt>innerHTML</tt>
  #   attribute will be used.
  # [:call]
  #   A name of a javascript function to be called for the text.
  # [:copied]
  #   Label text to show next to the icon after a successful copy action.
  # [:copyto]
  #   Label text to show next to the icon before it is clicked.
  # [:callBack]
  #   A name of a javascript function to be called after a successful copy
  #   action. The function will be called with one argument which is the value
  #   of the <tt>text</tt>, <tt>id</tt>, or <tt>call</tt> parameter, whichever
  #   was used.
  def clippy(options={})
    options = options.symbolize_keys
    if options[:text].nil? and options[:id].nil? and options[:call].nil?
      raise(ArgumentError, "at least :text, :id, or :call has to be provided")
    end
    bg_color = options.delete(:bg_color)
    query_string = options.to_query

    html = <<-EOF
    <object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000"
            width="14"
            height="14"
            id="clippy-#{ rand().object_id }" >
    <param name="movie" value="/flash/clippy.swf" />
    <param name="allowScriptAccess" value="always" />
    <param name="quality" value="high" />
    <param name="scale" value="noscale" />
    <param NAME="FlashVars" value="#{ query_string }">
    <param name="bgcolor" value="#{ bg_color }">
    <embed src="/flash/clippy.swf"
           width="14"
           height="14"
           name="clippy"
           quality="high"
           allowScriptAccess="always"
           type="application/x-shockwave-flash"
           pluginspage="http://www.macromedia.com/go/getflashplayer"
           FlashVars="#{ query_string }"
           bgcolor="#{ bg_color }"
    />
    </object>
  EOF

  end

  def application_version
    Mconf::VERSION
  end

  def application_revision
    Mconf.application_revision
  end

  def application_branch
    Mconf.application_branch
  end

  def github_link_to_revision(revision)
    "https://github.com/mconf/mconf-web/commit/#{revision}"
  end

  # Ex: asset_exists?('news/edit', 'css')
  def asset_exists?(asset_name, default_ext)
    !Mconf::Application.assets.find_asset(asset_name + '.' + default_ext).nil?
  end

  # Includes javascripts for the current controller and action
  # Example: 'assets/events/_all.js' and 'assets/events/show.js'
  def javascript_include_tags_for_action
    ["_all", params[:action]].each do |action|
      asset = "#{params[:controller]}/#{action}"
      concat(javascript_include_tag(asset)) if asset_exists?(asset, "js")
    end
  end

  # Includes stylesheets for the current controller and action
  # Example: 'assets/events/_all.css' and 'assets/events/show.css'
  def stylesheet_link_tags_for_action
    ["_all", params[:action]].each do |action|
      asset = "#{params[:controller]}/#{action}"
      concat(stylesheet_link_tag(asset)) if asset_exists?(asset, "css")
    end
  end

  # Renders the partial 'layout/page_title'
  # useful to simplify the calls from the views
  # Ex:
  #   <%= render_page_title('users', 'logos/user.png', { :transparent => true }) %>
  def render_page_title(title, logo=nil, options={})
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


  # TODO: All the code below should be reviewed

  def options_for_select_with_class_selected(container, selected = nil)
    container = container.to_a if Hash === container
    selected, disabled = extract_selected_and_disabled(selected)

    options_for_select = container.inject([]) do |options, element|
      text, value = option_text_and_value(element)
      selected_attribute = ' selected="selected" class="selected"' if option_value_selected?(value, selected)
      disabled_attribute = ' disabled="disabled"' if disabled && option_value_selected?(value, disabled)
      options << %(<option value="#{html_escape(value.to_s)}"#{selected_attribute}#{disabled_attribute}>#{html_escape(text.to_s)}</option>)
    end
    options_for_select.join("\n")
  end

  # Initialize an object for a form with suitable params
  def prepare_for_form(obj, options = {})
    case obj
    when Post
      #obj.attachments.build
      obj.attachments << Attachment.new if obj.new_record? && obj.attachments.blank?

      obj.space = @space if obj.space.blank?
    when Attachment
      obj.space = @space if obj.space.blank?
    when AgendaEntry
       obj.attachments << Attachment.new if obj.new_record? && obj.attachments.blank?
       obj.attachment_video ||= AttachmentVideo.new
    else
      raise "Unknown object #{ obj.class }"
    end

    options.each_pair do |method, value|  # Set additional attributes like:
      obj.__send__ "#{ method }=", value         # post.event = @event
    end

    obj
  end

  def generate_html(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f

    form_builder.fields_for(method, options[:object], :child_index => 'NEW_RECORD') do |f|
      locals = { options[:form_builder_local] => f }
      render(:partial => options[:partial], :locals => locals)
    end
  end

  def generate_template(form_builder, method, options = {})
    escape_javascript generate_html(form_builder, method, options)
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
