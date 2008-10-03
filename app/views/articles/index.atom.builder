    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema'}) do |feed|
      feed.title("Posts")
      feed.updated((@entries.first.updated_at unless @entries.first==nil))

      for article in @entries
        feed.entry(article.content, :url => space_article_path(@space, article.content)) do |entry|
          entry.title(article.name)
          entry.content(article.content.text, :type => "html")
          entry.tag!('sir:parent_id', article.parent_id)
          
          article.tags.each do |tag|
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
