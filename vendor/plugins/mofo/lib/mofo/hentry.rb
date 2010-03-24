# => http://microformats.org/wiki/hatom
require 'microformat'
require 'mofo/hcard'
require 'mofo/rel_tag'
require 'mofo/rel_bookmark'

class HEntry < Microformat
  one :entry_title, :entry_summary, :updated, :published,
      :author => HCard

  many :entry_content => :html, :tags => RelTag 

  after_find do
    @domain = @base_url.to_s.sub /http:\/\/([^\/]+).*/, '\1'
    @updated ||= @published if @published
  end

  def atom_id
    "<id>tag:#{@domain},2008-01-22:#{Digest::MD5.hexdigest(entry_content)}</id>"
  end

  def atom_link
    %(<link type="text/html" href="http://#{@domain}#{@bookmark}" rel="alternate"/>)
  end

  def to_atom(property = nil, value = nil)
    require 'digest/md5'
    require 'erb'

    if property
      value ||= instance_variable_get("@#{property}")
      return value ? ("<#{property}>%s</#{property}>" % value) : nil
    end

    entity = <<-atom_entity
  <entry>
    #{atom_id}
    #{atom_link}
    #{to_atom :title, @entry_title}
    #{to_atom :updated, @updated.try(:xmlschema)}
    <author>
      #{to_atom :name, @author.try(:fn)}
      #{to_atom :email, @author.try(:email)}
    </author>
    <content type="html">#{ERB::Util.h @entry_content}</content>
  </entry>
    atom_entity
  end

  def missing_author?
    @author.nil?
  end

  def add_in_parent_hcard
    @properties << 'author'
    @author = in_parent_hcard
  end

  # Per spec: if the entry author is missing find the nearest in
  # parent <address> element(s) with class name author
  def in_parent_hcard
    @in_parent_hcard ||= self.class.find_in_parent_hcard
  end

  def self.build_class(microformat)
    hentry = super(microformat)
    hentry.add_in_parent_hcard if hentry.missing_author?
    hentry
  end

  def self.find_in_parent_hcard
    author = HCard.find(:text => (@doc/"//.hentry/..//address.vcard").to_s)
    raise InvalidMicroformat if @options[:strict] && author.empty?
    prepare_value(author)
  end
end

class Array
  def to_atom(options = {})
    entries = map { |entry| entry.try(:to_atom) }.compact.join("\n")
    <<-end_atom
<?xml version="1.0" encoding="UTF-8"?>
<feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom">
  <id>#{first.base_url}</id>
  <link type="text/html" href="#{first.base_url}" rel="alternate"/>
  <title>#{options[:title]}</title>
  <updated>#{(first.updated || first.published).try(:xmlschema)}</updated>
  #{entries}
</feed>
    end_atom
  end
end
