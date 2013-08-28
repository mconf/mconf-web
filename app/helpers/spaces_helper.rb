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
  # current user. If there's no current user, returns a button to register.
  # If the user is already a member of the space, returns nil.
  def space_join_button(space, options={})
    # no user logged, renders a register button
    if !user_signed_in?
      unless options.has_key?(:skip_register) and options[:skip_register]
        link_to t('register.one'), register_path, options
      end

    # a user is logged and he's not in the space
    elsif !space.users.include?(current_user)
      link_to t('space.join'), new_space_join_request_path(space), options

    # the user already requested to join the space
    elsif space.pending_join_request_for?(current_user)
      options[:class] = "#{options[:class]} disabled tooltipped upwards"
      options[:title] = t("space.join_pending")
      content_tag(:span, t('space.join'), options)
    end
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
