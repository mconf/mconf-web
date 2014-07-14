# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module SpacesHelper

  # Stores the current tab in the menu for spaces
  def spaces_menu_at(tab)
    @spaces_menu_tab = tab
  end

  # Selects the tab if it is the current tab in the menu for spaces
  def spaces_menu_select_if(tab, options={})
    old_class = options[:class] || ''
    @spaces_menu_tab == tab ?
      options.update({ :class => "#{old_class} selected" }) :
      options
  end

  # Returns a link to join the space depending on the status of the
  # current user. Possible cases:
  # * If there's no current user, returns a button to register.
  # * If the user has already requested to join the space, shows a disabled button
  #   informing him of that.
  # * If the user was already invited to join the space, shows a button that
  #   goes to the page to accept/decline the invitation.
  # * If the user is already a member of the space, returns nil.
  def space_join_button(space, options={})
    options[:class] = "#{options[:class]} btn btn-large btn-block"

    # no user logged, renders a register button
    if !user_signed_in?
      options[:class] = "#{options[:class]} btn-success"
      if Site.current.registration_enabled?
        link_to t('_other.register'), register_path, options
      else
        link_to t('_other.login'), login_path, options
      end

    # the user already requested to join the space
    elsif space.pending_join_request_for?(current_user)
      request = space.pending_join_request_for(current_user)
      options[:class] = "#{options[:class]} btn-success disabled"
      button = content_tag :span, t('spaces.space_join_button.already_requested'), options
      alert = content_tag :div, :class => "alert alert-success" do
        link = link_to t("spaces.space_join_button.cancel_request"), space_join_request_path(space, request)
        text = content_tag :span, t("spaces.space_join_button.already_requested_alert")
        text + link
      end
      button + alert

    # the user was already invited to join the space
    elsif space.pending_invitation_for?(current_user)
      invitation = space.pending_invitation_for(current_user)
      options[:class] = "#{options[:class]} btn-success"
      icon = content_tag :i, "", :class => "icon-exclamation-sign"
      link = link_to icon + " " + t('spaces.space_join_button.accept_or_decline'), space_join_request_path(space, invitation), options
      alert = content_tag :div, t("spaces.space_join_button.invitation_alert"), :class => "alert alert-success"
      link + alert

    # a user is logged and he's not in the space
    elsif !space.users.include?(current_user)
      options[:class] = "#{options[:class]} btn-success"
      link_to t('spaces.space_join_button.join'), new_space_join_request_path(space), options
    end

  end

  # Stores the current tab in the menu in the administration pages of a space
  def spaces_admin_menu_at(tab)
    @spaces_admin_menu_tab = tab
  end

  # Selects the tab if it is the current tab in the administration menu of a spaces
  def spaces_admin_menu_select_if(tab, options={})
    old_class = options[:class] || ''
    @spaces_admin_menu_tab == tab ?
      options.update({ :class => "#{old_class} active" }) :
      options
  end

  # Stores the current tab in the menu in the webconference pages of a space
  def spaces_webconference_menu_at(tab)
    @spaces_webconference_menu_tab = tab
  end

  # Selects the tab if it is the current tab in the webconference pages of a space
  def spaces_webconference_menu_select_if(tab, options={})
    old_class = options[:class] || ''
    @spaces_webconference_menu_tab == tab ?
    options.update({ :class => "#{old_class} active" }) :
      options
  end

  # TODO: check the methods below

  def max_word_length text
    first_pos = 0
    max_length = 0
    while !((pos = (text+" ").index(' ', first_pos)).nil?)
      if (pos - first_pos) > max_length
        max_length = pos - first_pos
      end
      first_pos = pos + 1
    end
    return max_length
  end

end
