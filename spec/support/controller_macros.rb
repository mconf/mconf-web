module ControllerMacros

  # Logs in with the user passed
  def login_as(user)
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
    user
  end

end
