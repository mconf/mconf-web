module Mconf
  class SSLClientCert

    # the key used to indicate in the session if the user is signed in
    # via certificate or not
    SESSION_KEY = :certificate_login

    def initialize(cert_str, session=nil)
      @session = session
      @user, @error = nil, nil

      if !certificate_login_enabled?
        @error = :not_enabled
        return
      end

      @cert_str = cert_str
      @certificate = read_cert(cert_str)

      if @certificate.blank?
        @error = :certificate
        return
      end
    end

    def create_user
      find_or_create_token_and_user

      if @user.errors.any?
        Rails.logger.error "SSLCLIENT: Error creating user #{@user.errors.inspect}"
        @user = nil
      else
        Rails.logger.info "SSLCLIENT: Creating user '#{@user.name}' '#{@user.email}'"
        Rails.logger.info @cert_str.inspect
      end
    end

    def error
      @error
    end

    def user
      @user
    end

    def certificate
      @certificate
    end

    # Mark in the session that the user signed in via Certificate and
    # set the current time user signed in
    def set_signed_in
      @user.signed_in_via_external = true
      @session[SESSION_KEY] = true unless @session.nil?
      @token.current_sign_in_at = Time.now.utc
      @token.save
    end

    def get_identifier
      get_field(certificate_id_field) || get_field('CN')
    end

    def get_email
      get_field('emailAddress') || get_subject_alt_field('email')
    end

    def get_name
      name = get_field(certificate_name_field) || get_field('CN')

      # Remove the numbers from names in the format "My Company Name:23166928000223"
      name.gsub(/:\d+$/, '')
    end

    private

    # Searches for a CertificateToken using data in the object and returns it. Creates
    # a new CertificateToken if no token is found and returns it.
    def find_or_create_token
      token = find_token
      token = create_token(get_identifier, get_public_key) if token.nil?
      token
    end

    # Finds the CertificateToken associated with the user whose information is stored
    # in the object.
    def find_token
      CertificateToken.find_by_identifier(get_identifier)
    end

    def certificate_login_enabled?
      Site.current.certificate_login_enabled?
    end

    # The unique field in the certificate
    def certificate_id_field
      Site.current.certificate_id_field || 'CN'
    end

    # The name of the user from the certificate
    def certificate_name_field
      Site.current.certificate_name_field || 'CN'
    end

    def find_or_create_token_and_user
      @token = find_or_create_token
      @user = @token.user

      if @user.nil?
        attrs = {}
        attrs[:profile] = Profile.new(
          {
            full_name: get_name,
            country: get_field('C'),
            organization: get_field('O'),
            city: get_field('L'),
            province: get_field('ST')
          }
        )
        attrs[:email] = attrs[:email] || get_email
        attrs[:username] = username_from_name(get_name)
        attrs[:profile_attributes] = { full_name: get_name }

        @user = User.new(attrs)
        @user.password = SecureRandom.hex(16)
        @user.skip_confirmation_notification!
        if @user.valid?
          @user.save!
          @user.confirm
        end

        @token.new_account = true # account created automatically, not by the user
        @token.user = @user
        @token.save!
      end
    end

    # Public key structure in ASN1 is { header, key }
    # We parse the der, get the second entry and unpack it in hex
    def get_public_key
      der = OpenSSL::ASN1.decode(@certificate.public_key.to_der).entries[1].value
      der.unpack('H*')[0]
    end

    # Read cert attributes using OpenSSL
    def read_cert cert_str
      begin
        OpenSSL::X509::Certificate.new(cert_str.to_s)
      rescue OpenSSL::X509::CertificateError
        nil
      end
    end

    def get_field(field_name)
      # OpenSSL should really have an accessor here
      @certificate.subject.to_a.select {|name, _, _| name == field_name }.first.try(:[], 1)
    end

    def get_subject_alt_field(field)
      @certificate.extensions.find {|e| e.oid == 'subjectAltName' }.value.match(/#{field}\:(.+?)\s*(,|$)/).try(:[], 1)
    end

    def username_from_name(un)
      un.gsub(/[\s:]/, '-').gsub(/[^a-zA-Z0-9]/, '').downcase
    end

    def create_token(id, key)
      attrs = {
        identifier: id,
        public_key: key
      }
      CertificateToken.new(attrs)
    end
  end
end
