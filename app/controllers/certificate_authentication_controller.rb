class CertificateAuthenticationController < ApplicationController

  layout :determine_layout
  def determine_layout
    if request.xhr?
      'modal'
    else
      'application'
    end
  end

  def login
    certificate = request.headers['SSL_CLIENT_CERT']

    @cert = Mconf::SSLClientCert.new(certificate)
    @user = @cert.user

    if @user.present?

      # If the user has permission, log him in
      if Mconf::AttributeCertificate::any_certificate?(@user)
        sign_in :user, @user
        redirect_to my_home_path if !request.xhr?

      # user present but has no permissions via his certificate
      else
        redirect_to certificate_pending_path(name: @user.name)
      end

    else
      error = @cert.error || 'unknown'
      flash[:error] = I18n.t("certificate_authentication.error.#{error}")
    end
  end

  # Serves the error modal
  def error
  end

  def pending
    # don't show it unless user logged via certificate
    # referers = [login_url, root_url, certificate_login_path]

    if user_signed_in?
      redirect_to root_path
    end
  end

end
