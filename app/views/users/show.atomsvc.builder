xml.instruct!
xml.service "xmlns" => "http://www.w3.org/2007/app", "xmlns:atom" => 'http://www.w3.org/2005/Atom' do
  # Workspaces are Containers current_agent can entry to:
  for container in @agent.stages
    xml.workspace do
      xml.tag!( "atom:title", container.name )
      # Collections are different type of Contents
      for content in container.accepted_content_types
        xml.collection (:href => polymorphic_url([ container, content.to_class.new ]) + '.atom') do
          xml.tag!("atom:title", "#{ container.name } - #{ content.to_class.named_collection }")
          xml.accept(true ? content.to_class.content_options[:atompub_mime_types] : nil)
        end
      end
    end
  end
end
