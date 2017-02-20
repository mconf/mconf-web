require 'net/http'

module Mconf
  module AttributeCertificate

    def self.any_certificate? user
      configs = AttributeCertificateConfiguration.first
      oid1 = AttributeRole.find_by_role_name('Global Admin').try(:oid)
      oid2 = AttributeRole.find_by_role_name('Normal User').try(:oid)

      unless configs.try(:enabled?) && configs.valid?
        Rails.logger.info 'AC: Attribute certificates not enabled or config is invalid'
        return false
      end

      if is_authorized?(configs.full_url, user.public_key, configs.oid_eea, oid1) ||
         is_authorized?(configs.full_url, user.public_key, configs.oid_eea, oid2)

         true # has some certificate present
      else
        Rails.logger.info "AC: user '#{user.name}' has no certificates for #{configs.oid_eea}"
        false
      end
    end

    def self.role_for? user, role
      configs = AttributeCertificateConfiguration.first
      oid = AttributeRole.find_by_role_name(role).try(:oid)

      if configs.try(:enabled?) && configs.valid? && oid.present?

        is_authorized? configs.full_url, user.public_key, configs.oid_eea, oid
      else
        false
      end
    end

    private

    def self.is_authorized? url, pk, oideea, oid
      ret = false

      Rails.logger.info "SOAP: call #{url} with (#{pk.try(:truncate, 10)}, #{oideea}, #{oid})"

      response = call_webservice(url, :is_authorized, publicKey: pk, oidEEA: oideea, oidPrerrogativa: oid)

      if response.present?
        ret = response[:is_authorized_response][:is_authorized_result]
      end
      ret
    end

    def self.call_webservice url, method, params
      ret = nil
      begin
        client = Savon.client(wsdl: url, ssl_verify_mode: :peer)
        response = client.call(method, message: params)

        if response.success?
          ret = response.to_hash

          Rails.logger.info "SOAP: response is #{ret.inspect}"
        else
          Rails.logger.error "SOAP: call has failed #{ret.inspect}"
        end

      rescue SocketError, Savon::Error => e
        Rails.logger.error "SOAP: could not connect to server #{url}"
        Rails.logger.error "SOAP: error was #{e.message.try(:truncate, 100)}"
      end
      ret
    end

  end
end
