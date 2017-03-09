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

    @cert = Mconf::SSLClientCert.new(certificate, session)

    if params[:join_only] == "false"
      @cert.create_user
      @user = @cert.user

      if @user.present?
        sign_in :user, @user
        @cert.set_signed_in

        redir_url = after_sign_in_path_for(current_user)
        respond_to do |format|
          format.json { render json: { result: true, redirect_to: redir_url }, status: 200 }
        end
      else
        error = @cert.error || 'unknown'
        msg = I18n.t("certificate_authentication.error.#{error}")

        respond_to do |format|
          format.json { render json: { result: false, error: msg }, status: 200 }
        end
      end

    else
      cert_name = @cert.join_only
      cookies[:join_only_certificate] = { :value => cert_name, :expires => Time.now + 300}
      respond_to do |format|
        format.json { render json: { result: true, redirect_to: user_return_to }, status: 200 }
      end
    end
  end

end
