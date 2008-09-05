xml.instruct!
xml.feed "xmlns" => 'http://www.w3.org/2005/Atom', "xmlns:app" => 'http://www.w3.org/2007/app' do
  xml.title(sanitize(@title))
  xml.id("tag:#{ controller.request.host_with_port },#{ @updated.year }:#{ @collection_path }")
  xml.link(:rel => 'alternate', :type => 'text/html', :href => @collection_path)
  xml.link(:rel => 'self', :type => 'application/atom+xml', :href => @collection_path + '.atom')
  xml.subtitle(sanitize(@description)) if @description
  xml.updated(@updated.xmlschema) 
  xml.author do 
    xml.name(@container ? @container.name : controller.request.host_with_port )
    xml.uri( @container ? polymorphic_url(@container, :only_path => false) : url_for(:controller => "/", :only_path => false) )
  end

  @entries.each do |entry|
    xml << render(:partial => "articles/entry", 
                  :locals => { :entry => entry, :defined_namespaces => true })
  end
end
