    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema', 'xmlns:thr' => 'http://purl.org/syndication/thread/1.0'}) do |feed|
      feed.title("Posts")
      feed.updated((@entries.first.updated_at unless @entries.first==nil))

      for article in @entries
        feed.entry(article.content, :url => space_article_path(@space, article.content)) do |entry|
          entry.title(article.title)
          entry.content(article.content.text, :type => "html")
          if article.parent_id
            entry.tag!('thr:in-reply-to', Entry.find_by_id(article.parent_id).content.id)
          end
          
          article.content.tags.each do |tag|
            entry.category(:term => tag.name)
          end
          
          if article.public_read == true
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
