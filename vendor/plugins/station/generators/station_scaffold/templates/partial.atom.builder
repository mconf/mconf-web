entry.title(:type => "xhtml") do 
  entry.div(sanitize(<%= singular_name %>.title), :xmlns => "http://www.w3.org/1999/xhtml")
end

entry.summary(:type => "xhtml") do
  entry.div(sanitize(<%= singular_name %>.description), :xmlns => "http://www.w3.org/1999/xhtml")
end if <%= singular_name %>.respond_to?(:description.) && <%= singular_name %>.description.present?

entry.tag!("app:edited", <%= singular_name %>.updated_at.xmlschema)

entry.link(:rel => 'edit', :href => polymorphic_url(<%= singular_name %>, :format => :atom))
  
options = {}
options[:src], options[:type] = ( <%= singular_name %>.format ?
  [ polymorphic_url(<%= singular_name %>, :format => <%= singular_name %>.format), <%= singular_name %>.mime_type.to_s ] :
  [ polymorphic_url(<%= singular_name %>), 'text/html' ] )

entry.content(options)
