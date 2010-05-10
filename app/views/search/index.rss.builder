contents = Array(@events) + Array(@posts) + Array(@users) + Array(@attachments) + Array(@agenda_entries)

contents = contents.sort{ |x, y| y.updated_at <=> x.updated_at }

xml.instruct!
xml.rss 'xmlns:app' => 'http://purl.org/atom/app#',
        'xmlns:atom' => 'http://www.w3.org/2005/Atom',
        'xmlns:media' => 'http://search.yahoo.com/mrss/',
        'xmlns:openSearch' => 'http://a9.com/-/spec/opensearchrss/1.0/',
        'xmlns:gd' => 'http://schemas.google.com/g/2005',
        'xmlns:gml' => 'http://www.opengis.net/gml',
        'xmlns:yt' => 'http://gdata.youtube.com/schemas/2007',
        'xmlns:georss' => 'http://www.georss.org/georss',
        :version => '2.0' do

  xml.channel do
    xml.description
    xml.tag! 'atom:id', controller.request.url
    xml.lastBuildDate contents.first.try(:updated_at) || Time.now
    xml.category 'http://gdata.youtube.com/schemas/2007#video', :domain => 'http://schemas.google.com/g/2005#kind'
    xml.title t('search.results')
    xml.image do
      xml.url "http://#{ controller.request.host_with_port }#{ image_path 'pic_vcc_logo_123x63.gif' }"
      xml.title t('search.results')
      xml.link spaces_url
    end
    xml.link spaces_url

    xml.managingEditor current_site.name
    xml.generator current_site.name

    xml.tag! 'openSearch:totalResults', contents.size
    xml.tag! 'openSearch:startIndex', 1
    xml.tag! 'openSearch:itemsPerPage', 25

   contents.each do |c|
      xml.item do
        xml.guid polymorphic_url(c)
        xml.pubDate c.created_at
        xml.tag! 'atom:updated', c.updated_at.xmlschema
        xml.title c.title
        xml.description c.respond_to?(:description) ? c.description : ""
        xml.link polymorphic_url(c)
        xml.author c.author.try(:name) if c.respond_to?(:author)

        xml.category 'Test', :domain => tags_url

        xml << ( render(:partial => "#{ c.class.to_s.tableize }/#{ c.class.to_s.underscore }",
               :object => c) || "" )
      end
    end
  end
end
