atom_feed('xmlns:gd' => 'http://schemas.google.com/g/2005',
          :root_url => space_news_index_url(space)) do |feed|
  feed.title("News - #{ space.name }")
  feed.updated(@news.any? && @news.first.updated_at || Time.now)
  feed.logo(logo_image_url(space, :size => 'h64'))

  @news.each do |my_new|
    feed.entry(my_new, :url => space_news_path(space, my_new)) do |entry|
      entry.title(sanitize my_new.title)
      entry.summary(sanitize my_new.text)

    end
  end
end
