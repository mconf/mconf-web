module FrontpageHelper

  # Methods needed to include devise's forms in the frontpage'
  def resource_name
    :user
  end
  def resource
    @resource ||= User.new
  end
  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

end
