return unless agenda_entry.recording? && agenda_entry.get_src_from_embed.present?

xml.tag! 'media:group' do
  xml.tag! 'media:category', "General",
           :label => 'Global Plaza Space',
           :scheme => 'http://gdata.youtube.com/schemas/2007/categories.cat'

  xml.tag! 'media:content',
            :url => agenda_entry.get_src_from_embed,
            :type => 'application/x-shockwave-flash',
            :medium => 'video',
            :isDefault => 'true',
            :expression => 'full',
            'yt:format' => '5'
  xml.tag! 'media:description', agenda_entry.description, :type => 'plain'

  xml.tag! 'media:keywords', 'tag1, tag2, tag3'

  xml.tag! 'media:player', :url => event_url(agenda_entry.event, :show_video => agenda_entry.id)
  xml.tag! 'media:thumbnail', :url => image_path(agenda_entry.thumbnail)
  xml.tag! 'media:title', agenda_entry.title, :type => 'plain'
end
