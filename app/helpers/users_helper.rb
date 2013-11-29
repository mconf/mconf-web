require 'version'

module UsersHelper

  def user_category user
    if user.superuser
      icon_superuser + t('_other.user.administrator')
    else
      icon_user + t('_other.user.normal_user')
    end
  end

end
