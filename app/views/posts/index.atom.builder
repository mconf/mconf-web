    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema', 'xmlns:thr' => 'http://purl.org/syndication/thread/1.0'}) do |feed|
      feed.title("Posts")
      feed.updated(@posts.first.updated_at if @posts.any?)

      for post in @posts
        feed.entry(post, :url => space_post_path(container, post)) do |entry|
          entry.title(sanitize(post.title))
          entry.content(sanitize(post.text), :type => "html")
          if post.parent_id
            entry.tag!('thr:in-reply-to', post.parent_id)
          end
          
          post.tags.each do |tag|
            entry.category(:term => tag.name)
          end
          
          if post.public_read == true
            entry.tag!('gd:visibility', "public")
          else 
            entry.tag!('gd:visibility', "private")
          end

          entry.author do |author|
            author.name("SIR")
          end
        end
      end
    end
