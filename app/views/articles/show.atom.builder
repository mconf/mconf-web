atom_entry(@entry.content, {'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema', 
  :url => formatted_space_article_path(@space, @entry.content, :atom), :root_url => space_article_path(@space, @entry.content)}) do |entry|
          entry.title(@entry.name)
          entry.content(@entry.content.text, :type => "html")
          if @entry.parent_id
            entry.tag!('thr:in-reply-to', Entry.find_by_id(@entry.parent_id).content.id)
          end
          
          @article.tags.each do |tag|
            entry.category(:term => tag.name)
          end
          
          if @entry.public_read == true
            entry.tag!('gd:visibility', "public")
          else 
            entry.tag!('gd:visibility', "private")
          end

          entry.author do |author|
            author.name("SIR")
          end
  
end
