module Mconf
  class SSLClientCert

    def initialize(cert_str)
      @user, @error = nil, nil

      if !certificate_login_enabled?
        @error = :not_enabled
        return
      end

      @certificate = read_cert(cert_str)

      if @certificate.blank?
        @error = :certificate
        return
      end

      find_or_create_user

      if @user.errors.any?
        Rails.logger.error "SSLCLIENT: Error creating user #{@user.errors.inspect}"
        @user = nil
      else
        Rails.logger.info "SSLCLIENT: Creating user '#{@user.name}' '#{@user.unique_name}' '#{@user.email}'"
        Rails.logger.info cert_str.inspect
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

    private

    def certificate_login_enabled?
      Site.current.certificate_login_enabled? && certificate_id_field.present?
    end

    # The unique field in the certificate
    def certificate_id_field
      Site.current.certificate_id_field || 'CN'
    end

    # The unique field in the user model which should be linked to the certificate
    def user_field
      Site.current.certificate_user_id_field || 'unique_name'
    end

    def find_or_create_user
      attrs = {}
      attrs[user_field] = get_user_field

      @user = User.where(attrs).first
      if @user.blank?
        attrs[:profile] = Profile.new({country: get_field('C'), organization: get_field('O'),
          city: get_field('L'), province: get_field('ST') })
        attrs[:email] = attrs[:email] || get_email_field
        attrs[:unique_name] = attrs[:unique_name] || get_field('CN')
        attrs[:_full_name] = get_name_without_cpf.titleize
        attrs[:username] = username_from_unique_name(get_name_without_cpf)
        attrs[:public_key] = get_public_key()
        @user = User.new(attrs)
        @user.password = SecureRandom.hex(16)
        @user.skip_confirmation_notification!
        if @user.valid?
          @user.save!
          @user.confirm!
        end
      end
      @user
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

    def get_field field_name
      # OpenSSL should really have an accessor here
      @certificate.subject.to_a.select {|name, _, _| name == field_name }.first.try(:[], 1)
    end

    def username_from_unique_name un
      un.gsub(/[\s:]/, '-').gsub(/[^a-zA-Z0-9]/, '').downcase
    end

    def get_user_field
      get_field(certificate_id_field) || get_field('CN')
    end

    def get_email_field
      get_field('emailAddress') || get_subject_alt_field('email')
    end

    def get_subject_alt_field field
      @certificate.extensions.find {|e| e.oid == 'subjectAltName' }.value.match(/#{field}\:(.+?)\s*(,|$)/).try(:[], 1)
    end

    def get_name_without_cpf
      get_field('CN').split(':')[0]
    end
  end
end
