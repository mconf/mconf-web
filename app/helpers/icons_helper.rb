module IconsHelper

  # Default link to open the popup to join a webconference using a mobile device
  # If url is nil, renders a disabled button
  def webconf_mobile_icon_link(url)
    cls = 'webconf-join-mobile-link button dark-gray-hover'
    unless url
      url = '#'
      cls += ' disabled login-to-enable'
    end

    link_to url, :class => cls  do
      content_tag :span, t('bigbluebutton_rails.rooms.join_mobile')
    end
  end

  # Default icon that shows a tooltip with help about something
  def help_icon(title, options={})
    cls = "help-icon tooltipped upwards "
    options[:class] = options.has_key?(:class) ? cls + options[:class] : cls
    options.merge!(:title => title)
    content_tag :div, nil, options
  end

  # Help icon but using a text instead of an image
  def text_help_icon(title, options={})
    cls = "text-help-icon tooltipped upwards "
    options[:class] = options.has_key?(:class) ? cls + options[:class] : cls
    options.merge!(:title => title)
    content_tag :span, "(?)", options
  end

  # Default icon that shows a tooltip with information about something
  def info_icon(title, options={})
    cls = "info-icon tooltipped upwards "
    options[:class] = options.has_key?(:class) ? cls + options[:class] : cls
    options.merge!(:title => title)
    content_tag :div, nil, options
  end

  # Default icon to a feed (rss, atom)
  def feed_icon(options={})
    cls = "feed-icon tooltipped upwards "
    options[:class] = options.has_key?(:class) ? cls + options[:class] : cls
    options.merge!(:alt => t('RSS'), :title => t('RSS'))
    content_tag :div, nil, options
  end

  # Default icon to an attachment
  def attachment_icon(title, options={})
    cls = "attachment-icon "
    options[:class] = options.has_key?(:class) ? cls + options[:class] : cls
    icon_constructor title, "icons/attach.png", options
  end

  # Default icon to a comment
  def comment_icon(title, options={})
    cls = "comment-icon "
    options[:class] = options.has_key?(:class) ? cls + options[:class] : cls
    icon_constructor title, "icons/comments.png", options
  end

  # Default icon to an event
  def event_icon(title, options={})
    cls = "event-icon "
    options[:class] = options.has_key?(:class) ? cls + options[:class] : cls
    icon_constructor title, "icons/date.png", options
  end

  # Default icon to news
  def news_icon(title, options={})
    cls = "news-icon "
    options[:class] = options.has_key?(:class) ? cls + options[:class] : cls
    icon_constructor title, "icons/newspaper.png", options
  end

  # Admin red icon
  def superuser_icon(options={})
    cls = "icon superuser-icon "
    options[:class] = options.has_key?(:class) ? cls + options[:class] : cls
    options[:size] = '12x12'
    image_tag "icons/superuser-12x12.png", options
  end

  private

  # Base method for most of the methods above
  def icon_constructor(title, img, options={})
    options[:class] += " tooltipped upwards"
    options.merge!(:alt => title, :title => title)
    image_tag img, options
  end

end
