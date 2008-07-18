xml.content(:type => "xhtml") do
  xml.div(:xmlns => "http://www.w3.org/1999/xhtml") do
    xml << sanitize(post.content.text)
  end
end
