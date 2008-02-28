# Entry can be rendered from a feed or stand-alone
# If alone, it has to define XML namespaces
defined_namespaces ||= false

namespaces = ( defined_namespaces ? {} : { "xmlns" => 'http://www.w3.org/2005/Atom', "xmlns:app" => 'http://www.w3.org/2007/app' } )

xml.entry namespaces do

  xml.title(:type => "xhtml") do
    xml.div(:xmlns => "http://www.w3.org/1999/xhtml") do
      xml << sanitize(post.title)
    end
  end

  xml.author do
    xml.name(post.agent.name)
    xml.uri(polymorphic_url(post.agent, :only_path => false))
  end

  xml.id("tag:#{ controller.request.host_with_port },#{ post.updated_at.year }:#{ post_url(post) }")
  xml.published(post.created_at.xmlschema)
  xml.updated(post.updated_at.xmlschema)
  xml.tag!("app:edited", post.updated_at.xmlschema)
  xml.link(:rel => 'alternate', :type => 'text/html', :href => post_url(post))
  xml.link(:rel => 'edit', :href => formatted_post_url(post, :atom))
  xml.link(:rel => 'edit-media', :href => formatted_update_data_post_url(post, :atom)) if post.content.content_options[:has_attachment]

  xml.summary(:type => "xhtml") do
    xml.div(:xmlns => "http://www.w3.org/1999/xhtml") do
      xml << sanitize(post.description)
    end
  end if post.description

  xml << render(:partial => "#{ post.content.class.to_s.tableize }/entry",
                :locals  => { :content => post.content })

end
