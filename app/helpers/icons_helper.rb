# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module IconsHelper

  # Default icon that shows a tooltip with help about something
  def icon_help(title, options={})
    icon_constructor title, "icon-awesome icon-question-sign icon-mconf-help", options
  end

  # Default icon that shows a tooltip with information about something
  def icon_info(title, options={})
    icon_constructor title, "icon-awesome icon-info-sign icon-mconf-info", options
  end

  # Default icon to a feed (rss)
  def icon_feed(options={})
    options.merge!(:alt => t('RSS'), :title => t('RSS'))
    icon_constructor t('RSS'), "icon-awesome icon-rss icon-mconf-rss", options
  end

  def icon_attachment(options={})
    icon_constructor '', "icon-awesome icon-paper-clip iconf-mconf-attachment", options
  end

  def icon_comment(title=nil, options={})
    icon_constructor title, "icon-awesome icon-comment icon-mconf-comment", options
  end

  def icon_comments(title=nil, options={})
    icon_constructor title, "icon-awesome icon-comments-alt icon-mconf-comments", options
  end

  def icon_event(title=nil, options={})
    icon_constructor title, "icon-awesome icon-calendar icon-mconf-event", options
  end

  def icon_news(title=nil, options={})
    icon_constructor title, "icon-awesome icon-bullhorn icon-mconf-news", options
  end

  # Admin red label/icon
  # Usually shown on top of an avatar.
  def icon_superuser(options={})
    icon_constructor nil, "icon-awesome icon-cogs icon-mconf-superuser", options
  end

  def icon_guest(options={})
    icon_constructor nil, "icon-awesome icon-meh icon-mconf-guest", options
  end

  # Conference "in progress" icon.
  def icon_in_progress(options={})
    icon_constructor nil, "icon-awesome icon-refresh icon-mconf-in-progress icon-spin", options
  end

  def icon_loading(options={})
    icon_constructor nil, "icon-awesome icon-refresh icon-mconf-loading icon-spin", options
  end

  def icon_spam(options={})
    icon_constructor t("_other.spam.tooltip"), "icon-awesome icon-warning-sign icon-mconf-spam", options
  end

  def icon_message(options={})
    if options.has_key?(:class) and options[:class].match(/active/)
      icon_constructor nil, "icon-awesome icon-envelope icon-mconf-message", options
    else
      icon_constructor nil, "icon-awesome icon-envelope-alt icon-mconf-message", options
    end
  end

  def icon_unread_message(options={})
    options[:title] ||= t("icons.unread_message")
    options[:class] = options.has_key?(:class) ? "#{options[:class]} active" : "active"
    icon_message(options)
  end

  def icon_home(options={})
    icon_constructor nil, "icon-awesome icon-home icon-mconf-home", options
  end

  def icon_logout(options={})
    icon_constructor nil, "icon-awesome icon-off icon-mconf-logout", options
  end

  def icon_profile(options={})
    icon_constructor nil, "icon-awesome icon-user icon-mconf-profile", options
  end

  def icon_account(options={})
    icon_constructor nil, "icon-awesome icon-wrench icon-mconf-account", options
  end

  def icon_activity(options={})
    icon_constructor nil, "icon-awesome icon-list-alt icon-mconf-activity", options
  end

  def icon_create(options={})
    icon_constructor nil, "icon-awesome icon-plus-sign icon-mconf-create", options
  end

  def icon_delete(options={})
    icon_constructor nil, "icon-awesome icon-trash icon-mconf-delete", options
  end

  def icon_disable(options={})
    icon_constructor nil, "icon-awesome icon-ban-circle icon-mconf-disable", options
  end

  def icon_confirm(options={})
    icon_constructor nil, "icon-awesome icon-ok-sign icon-mconf-confirm", options
  end

  def icon_confirm_user(options={})
    icon_constructor nil, "icon-awesome fa fa-check-circle icon-mconf-confirm-user", options
  end

  def icon_enable(options={})
    icon_constructor nil, "icon-awesome icon-check icon-mconf-enable", options
  end

  def icon_users(options={})
    icon_constructor nil, "icon-awesome icon-group icon-mconf-users", options
  end

  def icon_edit(options={})
    icon_constructor nil, "icon-awesome icon-edit icon-mconf-edit", options
  end

  def icon_share(options={})
    icon_constructor nil, "icon-awesome icon-share icon-mconf-share", options
  end

  def icon_download(options={})
    icon_constructor nil, "icon-awesome icon-download-alt icon-mconf-download", options
  end

  def icon_attachment_new_version(options={})
    icon_constructor nil, "icon-awesome icon-plus-sign icon-mconf-attachment-new-version", options
  end

  def icon_new_tag(options={})
    icon_constructor nil, "icon-awesome icon-tags icon-mconf-new-tag", options
  end

  def icon_space_private(options={})
    icon_constructor nil, "icon-awesome icon-lock icon-mconf-space-private", options
  end

  def icon_space_public(options={})
    icon_constructor nil, "icon-awesome icon-eye-open icon-mconf-space-public", options
  end

  def icon_webconf_start(options={})
    icon_constructor nil, "icon-awesome icon-chevron-sign-right icon-mconf-webconf-start", options
  end

  def icon_mobile(options={})
    icon_constructor nil, "icon-awesome icon-mobile-phone icon-mconf-mobile", options
  end

  def icon_order_number_asc(options={})
    icon_constructor nil, "icon-awesome icon-sort-by-order icon-mconf-order-number-asc", options
  end

  def icon_order_number_desc(options={})
    icon_constructor nil, "icon-awesome icon-sort-by-order-alt icon-mconf-order-number-desc", options
  end

  def icon_check(options={})
    icon_constructor nil, "icon-awesome icon-check icon-mconf-check", options
  end

  def icon_list(options={})
    icon_constructor nil, "icon-awesome icon-list icon-mconf-list", options
  end

  def icon_picture(options={})
    icon_constructor nil, "icon-awesome icon-picture icon-mconf-picture", options
  end

  def icon_playback(options={})
    icon_constructor nil, "icon-awesome icon-play-sign icon-mconf-playback", options
  end

  def icon_date(options={})
    icon_constructor nil, "icon-awesome icon-calendar-empty icon-mconf-date", options
  end

  def icon_user(options={})
    icon_constructor nil, "icon-awesome icon-user icon-mconf-user", options
  end

  def icon_space(options={})
    icon_constructor nil, "icon-awesome icon-group icon-mconf-space", options
  end

  def icon_error(options={})
    icon_constructor nil, "icon-awesome icon-meh icon-mconf-error", options
  end

  def icon_success(options={})
    icon_constructor nil, "icon-awesome icon-ok icon-mconf-success", options
  end

  def icon_meeting(options={})
    icon_constructor nil, "icon-awesome icon-facetime-video icon-mconf-meeting", options
  end

  def icon_recording(options={})
    icon_constructor nil, "icon-awesome icon-youtube-play icon-mconf-recording", options
  end

  def icon_nested_child(options={})
    icon_constructor nil, "icon-awesome icon-level-up icon-rotate-90 icon-mconf-nested-child", options
  end

  def icon_approve(options={})
    icon_constructor nil, "icon-awesome fa fa-thumbs-up icon-mconf-approve", options
  end

  def icon_disapprove(options={})
    icon_constructor nil, "icon-awesome fa fa-thumbs-down icon-mconf-disapprove", options
  end

  def icon_is_member(options={})
    icon_constructor nil, "icon-awesome icon-check icon-mconf-is-member", options
  end

  def icon_options(options={})
    icon_constructor nil, "icon-awesome icon-gears icon-mconf-options", options
  end

  def icon_join_request(options={})
    icon_constructor nil, "icon-awesome icon-hand-up icon-mconf-join-request", options
  end

  def icon_join_space(options={})
    icon_constructor nil, "icon-awesome icon-signin icon-mconf-join-space", options
  end

  def icon_leave_space(options={})
    icon_constructor nil, "icon-awesome icon-signout icon-mconf-leave-space", options
  end

  def icon_participant_confirmed(options={})
    icon_constructor nil, "icon-awesome icon-ok icon-mconf-participant-confirmed", options
  end

  def icon_participant_not_confirmed(options={})
    icon_constructor nil, "icon-awesome icon-remove icon-mconf-participant-not-confirmed", options
  end

  private

  # Base method for most of the methods above
  def icon_constructor(title=nil, cls=nil, options={})
    options[:class] = options.has_key?(:class) ? cls + " " + options[:class] : cls
    title = title.nil? ? options[:title] : title
    unless title.nil? or title.blank?
      options = options_for_tooltip(title, options)
    end
    content_tag :i, nil, options
  end

  def text_icon_constructor(title, cls=nil, text=nil, options={})
    options[:class] = options.has_key?(:class) ? cls + options[:class] : cls
    content_tag :span, text, options_for_tooltip(title, options)
  end
end
