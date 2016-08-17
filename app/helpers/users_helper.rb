# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'version'

module UsersHelper

  def user_category user
    if user.superuser
      icon_superuser + t('_other.user.administrator')
    elsif user.new_record?
      icon_guest + t('_other.user.guest')
    elsif !user.approved?
      content_tag :div, :class => 'user-waiting-moderation' do
        concat icon_user(:class => 'user-unapproved') + t('_other.user.unapproved_user')
      end
    else
      icon_user + t('_other.user.normal_user')
    end
  end

  # The user's timezone is set in Rails in every request (see ApplicationController),
  # so we can just get it from Rails here and returned it formatted to the views.
  def user_timezone
    Time.zone.name
  end

  def user_timezone_offset
    offset = Time.zone.utc_offset
    offset += 3600 if Time.zone.now.dst?
    "GMT#{ActiveSupport::TimeZone.seconds_to_utc_offset(offset)}"
  end

  # Returns a string which can quickly give some info about the user in the form of
  #   "(username, email)"
  # The email will not be included if the user seeing the string does not have
  # permission to view private profile info for the user
  def user_info_string user
    "(#{user.username}#{", " + user.email if can?(:show, user.profile)})".html_safe
  end

end
