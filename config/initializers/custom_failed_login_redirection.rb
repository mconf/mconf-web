class CustomFailedLoginRedirection < Devise::FailureApp
  def redirect_url
    if warden_message == :not_approved
      my_approval_pending_path
    else
      super
    end
  end
end