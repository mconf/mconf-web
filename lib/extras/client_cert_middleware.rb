class ClientCertMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    ssl_failed = false

    if /^\/users\/certificate(.json)/.match env['REQUEST_URI']
      ENV['SSL_CLIENT_CERT'] ||= ''
      ENV['SSL_CLIENT_CERT_PRIVATE_KEY_FILE'] ||=''

      cert = IO.read(ENV['SSL_CLIENT_CERT']) if File.exists?(ENV['SSL_CLIENT_CERT'])
      ca = IO.read(ENV['SSL_CLIENT_CERT_PRIVATE_KEY_FILE']) if File.exists?(ENV['SSL_CLIENT_CERT_PRIVATE_KEY_FILE'])
      cert = read_cert(cert)
      ca = get_private_key(ca)

      if cert.present? && ca.present? # if cert and ca are present validate it and send error if invalid
        if cert.verify(ca)
          env['SSL_CLIENT_CERT'] = cert
        else
          ssl_failed = true
        end
      elsif cert.present? # if only cert is used just send it anyway to debug
        env['SSL_CLIENT_CERT'] = cert
      end
    end

    if ssl_failed
      @status, @headers, @response = 500, {}, 'SSL handshake failed'
    else
      @status, @headers, @response = @app.call(env)
    end

    [@status, @headers, @response]
  end

  private
  def get_private_key file
    file ||= ''
    begin
      OpenSSL::PKey::RSA.new(file)
    rescue OpenSSL::PKey::RSAError # wrong key password of key not found
      nil
    end
  end

  def read_cert file
    file ||=''
    begin
      OpenSSL::X509::Certificate.new(file)
    rescue OpenSSL::X509::CertificateError
      nil
    end
  end

end
