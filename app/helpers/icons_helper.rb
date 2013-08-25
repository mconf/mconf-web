# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module IconsHelper

  # Default icon that shows a tooltip with help about something
  def help_icon(title, options={})
    icon_constructor title, "icon help-icon", nil, options
  end

  # Help icon but using a text instead of an image
  def text_help_icon(title, options={})
    text_icon_constructor title, "icon text-help-icon", "(?)", options
  end

  # Default icon that shows a tooltip with information about something
  def info_icon(title, options={})
    icon_constructor title, "icon info-icon", nil, options
  end

  # Default icon to a feed (rss)
  def feed_icon(options={})
    options.merge!(:alt => t('RSS'), :title => t('RSS'))
    icon_constructor t('RSS'), "icon feed-icon", nil, options
  end

  # Default icon to an attachment
  def attachment_icon(title, options={})
    icon_constructor title, "icon attachment-icon", "icons/attach.png", options
  end

  # Default icon to a comment
  def comment_icon(title, options={})
    icon_constructor title, "icon comment-icon", "icons/comments.png", options
  end

  # Default icon to an event
  def event_icon(title, options={})
    icon_constructor title, "icon event-icon", "icons/date.png", options
  end

  # Default icon to news
  def news_icon(title="", options={})
    icon_constructor title, "icon news-icon", "icons/newspaper.png", options
  end

  # Admin red label/icon
  # Usually shown on top of an avatar.
  def superuser_label(options={})
    text = content_tag :i, nil, :class => "icon-asterisk"
    text_icon_constructor t('admin.one'), "icon superuser-icon", text, options
  end

  # Conference "in progress" icon.
  def in_progress_icon(options={})
    icon_constructor "" , "icon in-progress-icon", nil, options
  end

  # Spam icon.
  def spam_icon(options={})
    icon_constructor t("spam.item"), "icon spam-icon", nil, options
  end

  # Unread message icon.
  def unread_message_icon(options={})
    title = options[:title] || t("icons.unread_message")
    icon_constructor title, "icon unread-message-icon", nil, options
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
