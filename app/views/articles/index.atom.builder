    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema', 'xmlns:thr' => 'http://purl.org/syndication/thread/1.0'}) do |feed|
      feed.title("Posts")
      feed.updated((@entries.first.updated_at unless @entries.first==nil))

      for _entry in @entries
        feed.entry(_entry.content, :url => space_article_path(@space, _entry.content)) do |entry|
          entry.title(_entry.content.title)
          entry.content(_entry.content.text, :type => "html")
          if _entry.parent_id
            entry.tag!('thr:in-reply-to', Entry.find_by_id(_entry.parent_id).content.id)
          end
          
          _entry.content.tags.each do |tag|
            entry.category(:term => tag.name)
          end
          
          if _entry.public_read == true
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
