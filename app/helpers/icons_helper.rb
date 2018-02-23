# coding: utf-8
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module IconsHelper

  # Default icon that shows a tooltip with help about something
  def icon_help(title=nil, options={})
    icon_constructor title, "fa fa-question-circle-o icon icon-help", options
  end

  # Default icon that shows a tooltip with information about something
  def icon_info(title=nil, options={})
    icon_constructor title, "fa fa-info-circle icon icon-info", options
  end

  # Default icon to a feed (rss)
  def icon_feed(options={})
    options.merge!(:alt => t('RSS'), :title => t('RSS'))
    icon_constructor t('RSS'), "fa fa-rss icon icon-rss", options
  end

  def icon_attachment(title=nil, options={})
    icon_constructor title, "fa fa-paperclip icon iconf-mconf-attachment", options
  end

  def icon_comment(title=nil, options={})
    icon_constructor title, "fa fa-comment icon icon-comment", options
  end

  def icon_comments(title=nil, options={})
    icon_constructor title, "fa fa-comments-o icon icon-comments", options
  end

  def icon_event(title=nil, options={})
    icon_constructor title, "fa fa-calendar icon icon-event", options
  end

  # Admin red label/icon
  # Usually shown on top of an avatar.
  def icon_superuser(options={})
    icon_constructor nil, "fa fa-wrench icon icon-superuser", options
  end

  def icon_guest(options={})
    icon_constructor nil, "fa fa-meh-o icon icon-guest", options
  end

  # Conference "in progress" icon.
  def icon_in_progress(options={})
    icon_constructor nil, "fa fa-refresh fa-spin icon icon-in-progress", options
  end

  def icon_loading(options={})
    icon_constructor nil, "fa-spin fa fa-refresh icon icon-loading", options
  end

  def icon_message(options={})
    if options.has_key?(:class) and options[:class].match(/active/)
      icon_constructor nil, "fa fa-envelope icon icon-message", options
    else
      icon_constructor nil, "fa fa-envelope-o icon icon-message", options
    end
  end

  def icon_unread_message(options={})
    options[:title] ||= t("icons.unread_message")
    options[:class] = options.has_key?(:class) ? "#{options[:class]} active" : "active"
    icon_message(options)
  end

  def icon_logout(options={})
    icon_constructor nil, "fa fa-power-off icon icon-logout", options
  end

  def icon_profile(options={})
    icon_constructor nil, "fa fa-user icon icon-profile", options
  end

  def icon_account(options={})
    icon_constructor nil, "fa fa-wrench icon icon-account", options
  end

  def icon_activity(options={})
    icon_constructor nil, "fa-list-alt icon icon-activity", options
  end

  def icon_create(options={})
    icon_constructor nil, "fa fa-plus-square-o icon icon-create", options
  end

  def icon_delete(options={})
    icon_constructor nil, "fa fa-trash-o icon icon-delete", options
  end

  def icon_disable(options={})
    icon_constructor nil, "fa fa-arrow-down icon icon-disable", options
  end

  def icon_enable(options={})
    icon_constructor nil, "fa fa-arrow-up icon icon-enable", options
  end

  def icon_confirm_user(options={})
    icon_constructor nil, "fa fa-check-circle icon icon-confirm-user", options
  end

  def icon_confirm(options={})
    icon_constructor nil, "fa fa-check-circle icon icon-confirm", options
  end

  def icon_users(options={})
    icon_constructor nil, "fa fa-users icon icon-users", options
  end

  def icon_edit(options={})
    icon_constructor nil, "fa fa-edit icon icon-edit", options
  end

  def icon_share(options={})
    icon_constructor nil, "fa fa-share-square-o icon icon-share", options
  end

  def icon_download(options={})
    icon_constructor nil, "fa fa-download icon icon-download", options
  end

  def icon_attachment_new_version(options={})
    icon_constructor nil, "fa fa-plus-circle icon icon-attachment-new-version", options
  end

  def icon_space_private(options={})
    icon_constructor t('_other.space.private_space'), "fa fa-lock icon icon-space-private", options
  end

  def icon_space_public(options={})
    icon_constructor t('_other.space.public_space'), "fa fa-globe icon icon-space-public", options
  end

  def icon_publish(options={})
    icon_constructor nil, "fa fa-eye icon icon-publish", options
  end

  def icon_unpublish(options={})
    icon_constructor nil, "fa fa-eye-slash icon icon-unpublish", options
  end

  def icon_mobile(options={})
    icon_constructor nil, "fa fa-mobile icon icon-mobile", options
  end

  def icon_order_number_asc(options={})
    icon_constructor nil, "fa fa-sort-numeric-asc icon icon-order-number-asc", options
  end

  def icon_order_number_desc(options={})
    icon_constructor nil, "fa fa-sort-numeric-desc icon icon-order-number-desc", options
  end

  def icon_check(options={})
    icon_constructor nil, "fa fa-check-square-o icon icon-check", options
  end

  def icon_picture(options={})
    icon_constructor nil, "fa fa-picture-o icon icon-picture", options
  end

  def icon_playback(options={})
    icon_constructor nil, "fa fa-play-circle icon icon-playback", options
  end

  def icon_date(options={})
    icon_constructor nil, "fa fa-calendar-o icon icon-date", options
  end

  def icon_user(options={})
    icon_constructor nil, "fa fa-user icon icon-user", options
  end

  def icon_space(options={})
    icon_constructor nil, "fa fa-group icon icon-space", options
  end

  def icon_error(options={})
    icon_constructor nil, "fa fa-meh-o icon icon-error", options
  end

  def icon_success(options={})
    icon_constructor nil, "fa fa-check icon icon-success", options
  end

  def icon_meeting(options={})
    icon_constructor nil, "fa fa-video-camera icon icon-meeting", options
  end

  def icon_recording(options={})
    icon_constructor nil, "fa fa-youtube-play icon icon-recording", options
  end

  def icon_approve(options={})
    icon_constructor nil, "fa fa-thumbs-o-up icon icon-approve", options
  end

  def icon_waiting_moderation(options={})
    icon_constructor t("_other.not_approved.tooltip"), "fa fa-exclamation-circle icon icon-waiting-moderation", options
  end

  def icon_disapprove(options={})
    icon_constructor nil, "fa fa-thumbs-o-down icon icon-disapprove", options
  end

  def icon_is_member(options={})
    icon_constructor nil, "fa fa-user-circle icon icon-is-member", options
  end

  def icon_options(options={})
    icon_constructor nil, "icon icon-mw-options icon-options", options
  end

  def icon_join_request(options={})
    icon_constructor nil, "fa fa-hand-o-up icon icon-join-request", options
  end

  def icon_join_space(options={})
    icon_constructor nil, "fa fa-sign-in icon icon-join-space", options
  end

  def icon_leave_space(options={})
    icon_constructor nil, "fa fa-sign-out icon icon-leave-space", options
  end

  def icon_invitation(options={})
    icon_constructor nil, "icon icon-mw-conference-invite icon-conference-invite", options
  end

  def icon_list(options={})
    icon_constructor nil, "fa fa-list icon icon-list", options
  end

  def icon_participant_confirmed(options={})
    icon_constructor nil, "fa fa-check icon icon-participant-confirmed", options
  end

  def icon_participant_not_confirmed(options={})
    icon_constructor nil, "fa fa-remove icon icon-participant-not-confirmed", options
  end

  def icon_external_link(options={})
    icon_constructor nil, "fa fa-external-link icon icon-external-link", options
  end

  def icon_can_rec(options={})
    icon_constructor nil, "fa fa-circle icon icon-can-rec", options
  end

  def icon_cant_rec(options={})
    icon_constructor nil, "fa fa-circle-o icon icon-cant-rec", options
  end

  def icon_later(options={})
    icon_constructor nil, "fa fa-clock-o icon icon-later", options
  end

  def icon_add_admin(options={})
    content_tag :div, :class => 'input-group' do
      concat icon_constructor nil, "fa fa-wrench icon icon-stack-superuser", options.clone
      concat icon_constructor nil, "fa fa-plus icon icon-stack-plus", options.clone
    end
  end

  def icon_add_user(options={})
    content_tag :div, :class => 'input-group' do
      concat icon_constructor nil, "fa fa-user icon icon-stack-user", options.clone
      concat icon_constructor nil, "fa fa-plus icon icon-stack-plus", options.clone
    end
  end

  def icon_conference_play(options={})
    icon_constructor nil, "icon icon-mw-conference-play icon-conference-play", options
  end

  def icon_rec_play(options={})
    icon_constructor nil, "icon icon-mw-conference-play icon-rec-play", options
  end

  def icon_rec_download(options={})
    icon_constructor nil, "icon icon-mw-rec-download icon-rec-download", options
  end

  def icon_published(options={})
    content_tag :div, "", class: "icon icon-published"
  end

  def icon_unpublished(options={})
    content_tag :div, "", class: "icon icon-unpublished"
  end

  def icon_options_dots(options={})
    icon_constructor nil, "icon icon-mw-options-dots icon-options-dots", options
  end

  def icon_login_facebook(options={})
    image_tag 'icons/login-facebook.svg', size: "46x46", class: ""
  end

  def icon_login_google(options={})
    image_tag 'icons/login-google.svg', size: "46x46", class: ""
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
