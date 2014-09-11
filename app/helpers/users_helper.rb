require 'version'

module UsersHelper

  def user_category user
    if user.superuser
      icon_superuser + t('_other.user.administrator')
    elsif user.new_record?
      icon_guest + t('_other.user.guest')
    elsif !user.approved?
      icon_user(:class => 'user-unapproved') + t('_other.user.unapproved_user')
    else
      icon_user + t('_other.user.normal_user')
    end
  end

  # The user's timezone is set in Rails in every request (see ApplicationController),
  # so we can just get it from Rails here and returned it formatted to the views.
  def user_timezone
    "GMT#{Time.zone.formatted_offset}"
  end

end
