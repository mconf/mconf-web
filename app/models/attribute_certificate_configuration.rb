class AttributeCertificateConfiguration < ActiveRecord::Base
  validates :repository_url, presence: true, if: :enabled?

  before_save :adjust_repository_url, if: :repository_url

  def full_url
    return '' if repository_url.blank?

    port = repository_port || '443'
    port_str = ":#{port}/" unless ['80','443'].include?(port)

    "http#{port == '443' ? 's' : ''}://#{repository_url}#{port_str}?wsdl"
  end


  private

  def adjust_repository_url
    repository_url.gsub!(/\?wsdl$/, '') # remove ?wsdl from the url
    repository_url.gsub!(/^https?:\/\//, '') # remove protocol from the start
  end

end
