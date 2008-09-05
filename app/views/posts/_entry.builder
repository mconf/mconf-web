# Entry can be rendered from a feed or stand-alone
# If alone, it has to define XML namespaces
defined_namespaces ||= false

namespaces = ( defined_namespaces ? {} : { "xmlns" => 'http://www.w3.org/2005/Atom', "xmlns:app" => 'http://www.w3.org/2007/app' } )

xml.entry namespaces do

  xml.title(:type => "xhtml") do
    xml.div(:xmlns => "http://www.w3.org/1999/xhtml") do
      xml << sanitize(entry.title)
    end
  end

  xml.author do
    xml.name(entry.agent.name)
    xml.uri(polymorphic_url(entry.agent, :only_path => false))
  end

  xml.id("tag:#{ controller.request.host_with_port },#{ entry.updated_at.year }:#{ entry_path(entry) }")
  xml.published(entry.created_at.xmlschema)
  xml.updated(entry.updated_at.xmlschema)
  xml.tag!("app:edited", entry.updated_at.xmlschema)
  xml.link(:rel => 'alternate', :type => 'text/html', :href => entry_url(entry))
  xml.link(:rel => 'edit', :href => formatted_entry_url(entry, :atom))
  xml.link(:rel => 'edit-media', :href => formatted_media_entry_url(entry, :atom)) if entry.has_media?

  xml.summary(:type => "xhtml") do
    xml.div(:xmlns => "http://www.w3.org/1999/xhtml") do
      xml << sanitize(entry.description)
    end
  end if entry.description

  xml << render(:partial => "#{ entry.content.class.to_s.tableize }/entry",
                :locals  => { :entry => entry })

end
