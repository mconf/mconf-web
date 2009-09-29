atom_feed('xmlns:gd' => 'http://schemas.google.com/g/2005', 
          'xmlns:thr' => 'http://purl.org/syndication/thread/1.0',
          :root_url => polymorphic_url([ space, Post.new ])) do |feed|
  feed.title("Posts - #{ sanitize space.name }")
  feed.updated(@posts.any? && @posts.first.updated_at || Time.now)
  feed.logo(logo_image_url(space, :size => 'h64'))

  @posts.each do |post|
    feed.entry(post, :url => space_post_url(space, post)) do |entry|
      entry.title(sanitize(post.title))
      entry.content(sanitize(post.text), :type => "html")

      if post.parent_id
        entry.tag!('thr:in-reply-to', post.parent_id)
      end
          
      post.tags.each do |tag|
        entry.category(:term => tag.name)
      end
          
      entry.author do |author|
        author.name(sanitize(post.author.name))
       end
    end
  end
end
