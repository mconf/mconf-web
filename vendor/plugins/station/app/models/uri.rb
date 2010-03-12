# Require Ruby URI Module, not defined by this file but with the 
# same source file name
URI

begin
  require 'atom/service'
rescue MissingSourceFile
  Rails.logger.info "Station Info: You need 'atom-tools' gem for AtomPub service document support"
end

begin
  require 'mofo'
rescue MissingSourceFile
  Rails.logger.info "Station Info: You need 'mofo' gem for Microformats support"
end

# URI storage in the database
class Uri < ActiveRecord::Base
  has_many :openid_ownings, 
           :class_name => "OpenIdOwning"
  has_many :openid_trusts,
           :class_name => "OpenIdTrust"
             
  # Return this URI string         
  def to_s
    self.uri
  end

  def to_uri
    @to_uri ||= ::URI.parse(self.uri)
  end

  # Dereference URI and return HTML document
  def html
    @html ||= Station::Html.new(dereference(:accept => 'text/html').body)
  end

  def dereference(options = {})
    # TODO?: non http(s) URIs
    return nil unless to_uri.scheme =~ /^(http|https)$/

    # Limit too many redirects
    options[:redirect] ||= 0
    return nil if options[:redirect] > 10

    http = Net::HTTP.new(to_uri.host, to_uri.port)
    http.use_ssl = to_uri.scheme == "https"
    path = to_uri.path.present? && to_uri.path || '/'
    path << "?#{ to_uri.query }" if to_uri.query.present?
    headers = {}
    headers['Accept'] = options[:accept] if options[:accept].present?
    response = http.get(path, headers)

    case response
    when Net::HTTPSuccess
      response
    when Net::HTTPRedirection
      options[:redirect] += 1
      self.class.new(:uri => response['location']).dereference(options)
    else
      nil
    end
  end

  # Returns the AtomPub Service Document associated with this URI.
  def atompub_service_document
    Atom::Service.discover self.uri
  end

  # Find hCard in this URI
  #
  # Needs the {mofo}[http://mofo.rubyforge.org/] gem
  def hcard
    hCard.find self.uri
  rescue
    nil
  end

  # Does this URI has a hCard attached?
  def hcard?
    hcard.present?
  end

  private

  # Extract service link from HTML head
  def parse_atompub_service_link(html) #:nodoc:
    # TODO: link service
    # TODO: meta refresh
    nil
  end
end
