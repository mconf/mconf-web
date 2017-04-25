# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module IconsHelper

  # Default icon that shows a tooltip with help about something
  def icon_help(title=nil, options={})
    icon_constructor title, "fa fa-question-circle-o icon-awesome icon-mconf-help", options
  end

  # Default icon that shows a tooltip with information about something
  def icon_info(title=nil, options={})
    icon_constructor title, "fa fa-info-circle icon-awesome icon-mconf-info", options
  end

  # Default icon to a feed (rss)
  def icon_feed(options={})
    options.merge!(:alt => t('RSS'), :title => t('RSS'))
    icon_constructor t('RSS'), "fa fa-rss icon-awesome icon-mconf-rss", options
  end

  def icon_attachment(title=nil, options={})
    icon_constructor title, "fa fa-paperclip icon-awesome iconf-mconf-attachment", options
  end

  def icon_comment(title=nil, options={})
    icon_constructor title, "fa fa-comment icon-awesome icon-mconf-comment", options
  end

  def icon_comments(title=nil, options={})
    icon_constructor title, "fa fa-comments-o icon-awesome icon-mconf-comments", options
  end

  def icon_event(title=nil, options={})
    icon_constructor title, "fa fa-calendar icon-awesome icon-mconf-event", options
  end

  # Admin red label/icon
  # Usually shown on top of an avatar.
  def icon_superuser(options={})
    icon_constructor nil, "fa fa-wrench icon-awesome icon-mconf-superuser", options
  end

  def icon_guest(options={})
    icon_constructor nil, "fa fa-meh-o icon-awesome icon-mconf-guest", options
  end

  # Conference "in progress" icon.
  def icon_in_progress(options={})
    icon_constructor nil, "fa fa-refresh fa-spin icon-awesome icon-mconf-in-progress", options
  end

  def icon_loading(options={})
    icon_constructor nil, "fa-spin fa fa-refresh icon-awesome icon-mconf-loading", options
  end

  def icon_message(options={})
    if options.has_key?(:class) and options[:class].match(/active/)
      icon_constructor nil, "fa fa-envelope icon-awesome icon-mconf-message", options
    else
      icon_constructor nil, "fa fa-envelope-o icon-awesome icon-mconf-message", options
    end
  end

  def icon_unread_message(options={})
    options[:title] ||= t("icons.unread_message")
    options[:class] = options.has_key?(:class) ? "#{options[:class]} active" : "active"
    icon_message(options)
  end

  def icon_logout(options={})
    icon_constructor nil, "fa fa-power-off icon-awesome icon-mconf-logout", options
  end

  def icon_profile(options={})
    icon_constructor nil, "fa fa-user icon-awesome icon-mconf-profile", options
  end

  def icon_account(options={})
    icon_constructor nil, "fa fa-wrench icon-awesome icon-mconf-account", options
  end

  def icon_activity(options={})
    icon_constructor nil, "fa-list-alt icon-awesome icon-mconf-activity", options
  end

  def icon_create(options={})
    icon_constructor nil, "fa fa-plus-square-o icon-awesome icon-mconf-create", options
  end

  def icon_delete(options={})
    icon_constructor nil, "fa fa-trash-o icon-awesome icon-mconf-delete", options
  end

  def icon_disable(options={})
    icon_constructor nil, "fa fa-arrow-down icon-awesome icon-mconf-disable", options
  end

  def icon_enable(options={})
    icon_constructor nil, "fa fa-arrow-up icon-awesome icon-mconf-enable", options
  end

  def icon_confirm_user(options={})
    icon_constructor nil, "fa fa-check-circle icon-awesome icon-mconf-confirm-user", options
  end

  def icon_confirm(options={})
    icon_constructor nil, "fa fa-check-circle icon-awesome icon-mconf-confirm", options
  end

  def icon_users(options={})
    icon_constructor nil, "fa fa-users icon-awesome icon-mconf-users", options
  end

  def icon_edit(options={})
    icon_constructor nil, "fa fa-edit icon-awesome icon-mconf-edit", options
  end

  def icon_share(options={})
    icon_constructor nil, "fa fa-share-square-o icon-awesome icon-mconf-share", options
  end

  def icon_download(options={})
    icon_constructor nil, "fa fa-download icon-awesome icon-mconf-download", options
  end

  def icon_attachment_new_version(options={})
    icon_constructor nil, "fa fa-plus-circle icon-awesome icon-mconf-attachment-new-version", options
  end

  def icon_space_private(options={})
    icon_constructor nil, "fa fa-lock icon-awesome icon-mconf-space-private", options
  end

  def icon_space_public(options={})
    icon_constructor nil, "fa fa-globe icon-awesome icon-mconf-space-public", options
  end

  def icon_publish(options={})
    icon_constructor nil, "fa fa-eye icon-awesome icon-mconf-publish", options
  end

  def icon_unpublish(options={})
    icon_constructor nil, "fa fa-eye-slash icon-awesome icon-mconf-unpublish", options
  end

  def icon_mobile(options={})
    icon_constructor nil, "fa fa-mobile icon-awesome icon-mconf-mobile", options
  end

  def icon_order_number_asc(options={})
    icon_constructor nil, "fa fa-sort-numeric-asc icon-awesome icon-mconf-order-number-asc", options
  end

  def icon_order_number_desc(options={})
    icon_constructor nil, "fa fa-sort-numeric-desc icon-awesome icon-mconf-order-number-desc", options
  end

  def icon_check(options={})
    icon_constructor nil, "fa fa-check-square-o icon-awesome icon-mconf-check", options
  end

  def icon_picture(options={})
    icon_constructor nil, "fa fa-picture-o icon-awesome icon-mconf-picture", options
  end

  def icon_playback(options={})
    icon_constructor nil, "fa fa-play-circle icon-awesome icon-mconf-playback", options
  end

  def icon_date(options={})
    icon_constructor nil, "fa fa-calendar-o icon-awesome icon-mconf-date", options
  end

  def icon_user(options={})
    icon_constructor nil, "fa fa-user icon-awesome icon-mconf-user", options
  end

  def icon_space(options={})
    icon_constructor nil, "fa fa-group icon-awesome icon-mconf-space", options
  end

  def icon_error(options={})
    icon_constructor nil, "fa fa-meh-o icon-awesome icon-mconf-error", options
  end

  def icon_success(options={})
    icon_constructor nil, "fa fa-check icon-awesome icon-mconf-success", options
  end

  def icon_meeting(options={})
    icon_constructor nil, "fa fa-video-camera icon-awesome icon-mconf-meeting", options
  end

  def icon_recording(options={})
    icon_constructor nil, "fa fa-youtube-play icon-awesome icon-mconf-recording", options
  end

  def icon_approve(options={})
    icon_constructor nil, "fa fa-thumbs-o-up icon-awesome icon-mconf-approve", options
  end

  def icon_waiting_moderation(options={})
    icon_constructor t("_other.not_approved.tooltip"), "fa fa-exclamation-circle icon-awesome icon-mconf-waiting-moderation", options
  end

  def icon_disapprove(options={})
    icon_constructor nil, "fa fa-thumbs-o-down icon-awesome icon-mconf-disapprove", options
  end

  def icon_is_member(options={})
    icon_constructor nil, "fa fa-user-circle icon-awesome icon-mconf-is-member", options
  end

  def icon_options(options={})
    icon_constructor nil, "fa fa-gears icon-awesome icon-mconf-options", options
  end

  def icon_join_request(options={})
    icon_constructor nil, "fa fa-hand-o-up icon-awesome icon-mconf-join-request", options
  end

  def icon_join_space(options={})
    icon_constructor nil, "fa fa-sign-in icon-awesome icon-mconf-join-space", options
  end

  def icon_leave_space(options={})
    icon_constructor nil, "fa fa-sign-out icon-awesome icon-mconf-leave-space", options
  end

  def icon_invitation(options={})
    icon_constructor nil, "fa fa-envelope-o icon-awesome icon-mconf-invitation", options
  end

  def icon_list(options={})
    icon_constructor nil, "fa fa-list icon-awesome icon-mconf-list", options
  end

  def icon_participant_confirmed(options={})
    icon_constructor nil, "fa fa-check icon-awesome icon-mconf-participant-confirmed", options
  end

  def icon_participant_not_confirmed(options={})
    icon_constructor nil, "fa fa-remove icon-awesome icon-mconf-participant-not-confirmed", options
  end

  def icon_external_link(options={})
    icon_constructor nil, "fa fa-external-link icon-awesome icon-external-link", options
  end

  def icon_can_rec(options={})
    icon_constructor nil, "fa fa-circle icon-awesome icon-mconf-can-rec", options
  end

  def icon_cant_rec(options={})
    icon_constructor nil, "fa fa-circle-o icon-awesome icon-mconf-cant-rec", options
  end

  def icon_later(options={})
    icon_constructor nil, "fa fa-clock-o icon-awesome icon-mconf-later", options
  end

  def icon_add_admin(options={})
    content_tag :div, :class => 'input-group' do
      concat icon_constructor nil, "fa fa-wrench icon-awesome icon-mconf-stack-superuser", options.clone
      concat icon_constructor nil, "fa fa-plus icon-awesome icon-mconf-stack-plus", options.clone
    end
  end

  def icon_add_user(options={})
    content_tag :div, :class => 'input-group' do
      concat icon_constructor nil, "fa fa-user icon-awesome icon-mconf-stack-user", options.clone
      concat icon_constructor nil, "fa fa-plus icon-awesome icon-mconf-stack-plus", options.clone
    end
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
