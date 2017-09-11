# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
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
      options.update({ :class => "#{old_class} active" }) :
      options
  end

  # Returns whether the selected menu is `tab`
  def spaces_menu_is(tab)
    @spaces_menu_tab == tab
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

    # no user logged, renders a register button
    if !user_signed_in?
      options[:class] = "#{options[:class]} btn btn-large btn-block btn-success"
      link_to t('_other.login'), login_path, options

    # the user already requested to join the space
    elsif space.pending_join_request_for?(current_user)
      request = space.pending_join_request_for(current_user)

      options[:class] = "#{options[:class]} btn btn-large btn-block btn-danger tooltipped"
      options[:data] = { confirm: t('spaces.space_join_button.cancel_confirm') }
      options[:method] = :post
      options[:title] = t("spaces.space_join_button.cancel_tooltip", message: request.comment)
      button = link_to t("spaces.space_join_button.cancel"), decline_space_join_request_path(space, request), options

      button

    # the user was already invited to join the space
    elsif space.pending_invitation_for?(current_user)
      invitation = space.pending_invitation_for(current_user)
      content_tag :div, class: "pending-join-request" do
        concat content_tag :span, t("spaces.space_join_button.invitation_alert")
        concat content_tag :div, icon_comments, class: 'comment', title: t("spaces.space_join_button.invitation_text"), data: { toggle: 'popover', trigger: 'focus', content: invitation.comment, placement: 'top' }, tabindex: 0, role: 'button'
        if can?(:accept, invitation)
          options[:class] = "#{options[:class]} btn btn-success"
          options[:method] = :post
          concat link_to t('spaces.space_join_button.accept'), accept_space_join_request_path(space, invitation), options
        end
        if can?(:decline, invitation)
          options[:class] = "#{options[:class]} btn btn-danger"
          options[:method] = :post
          options[:data] = { confirm: t('spaces.space_join_button.decline_confirm') }
          concat link_to t('spaces.space_join_button.decline'), decline_space_join_request_path(space, invitation), options
        end
      end

    # a user is logged and he's not in the space
    elsif !space.users.include?(current_user)
      options[:class] = "#{options[:class]} btn btn-large btn-block btn-success open-modal"
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

  # Returns whether the selected tab is `tab`
  def spaces_admin_menu_is(tab)
    @spaces_admin_menu_tab == tab
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

  def space_visibility(space)
    if space.public
      content_tag :div, class: 'label label-success' do
        concat icon_space_public + t('_other.space.public')
      end
    else
      content_tag :div, class: 'label label-danger' do
        concat icon_space_private + t('_other.space.private')
      end
    end
  end

  def link_to_tag(tag)
    if current_page?(manage_spaces_path) || current_page?(spaces_path)
      # in these pages, the links are to add a tag to the current filters
      link_to tag, '#', data: { qstring: "tag+=#{tag}", "qstring-sep": "," }
    else
      # in all other pages the link is to space/index filtering by the tag clicked
      options = params.clone
      options.delete(:id) if options.has_key?(:id)
      link_to tag.name, spaces_path(options.merge(tag: tag.name))
    end
  end

end
