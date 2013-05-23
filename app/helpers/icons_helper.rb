# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module IconsHelper

  # Default link to open the popup to join a webconference using a mobile device
  # If url is nil, renders a disabled button
  def webconf_mobile_icon_link(url)
    cls = 'webconf-join-mobile-link btn btn-small dark-gray-hover'
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
    icon_constructor title, "help-icon", nil, options
  end

  # Help icon but using a text instead of an image
  def text_help_icon(title, options={})
    text_icon_constructor title, "text-help-icon", "(?)", options
  end

  # Default icon that shows a tooltip with information about something
  def info_icon(title, options={})
    icon_constructor title, "info-icon", nil, options
  end

  # Default icon to a feed (rss)
  def feed_icon(options={})
    options.merge!(:alt => t('RSS'), :title => t('RSS'))
    icon_constructor t('RSS'), "feed-icon", nil, options
  end

  # Default icon to an attachment
  def attachment_icon(title, options={})
    icon_constructor title, "attachment-icon", "icons/attach.png", options
  end

  # Default icon to a comment
  def comment_icon(title, options={})
    icon_constructor title, "comment-icon", "icons/comments.png", options
  end

  # Default icon to an event
  def event_icon(title, options={})
    icon_constructor title, "event-icon", "icons/date.png", options
  end

  # Default icon to news
  def news_icon(title, options={})
    icon_constructor title, "news-icon", "icons/newspaper.png", options
  end

  # Admin red label/icon
  # Usually shown on top of an avatar.
  def superuser_icon(options={})
    text_icon_constructor "", "superuser-icon label label-important", t('admin.one'), options
  end

  # Conference "in progress" icon.
  def in_progress_icon(options={})
    icon_constructor "" , "in-progress-icon", nil, options
  end

  # Spam icon.
  def spam_icon(options={})
    icon_constructor t("spam.item"), "spam-icon", nil, options
  end

  private

  # Base method for most of the methods above
  def icon_constructor(title, cls=nil, img=nil, options={})
    options[:class] = options.has_key?(:class) ? cls + " " + options[:class] : cls
    options = options_for_tooltip(title, options)
    if (img)
      image_tag img, options
    else
      content_tag :div, nil, options
    end
  end

  def text_icon_constructor(title, cls=nil, text=nil, options={})
    options[:class] = options.has_key?(:class) ? cls + options[:class] : cls
    content_tag :span, text, options_for_tooltip(title, options)
  end
end
