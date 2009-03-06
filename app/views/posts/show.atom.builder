atom_entry(@article, {'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema', 
  :url => formatted_space_article_path(@space, @article, :atom), :root_url => space_article_path(@space, @article)}) do |entry|
          entry.title(@article.title)
          entry.content(@article.text, :type => "html")
          if @article.entry.parent_id
            entry.tag!('thr:in-reply-to', Entry.find_by_id(@article.entry.parent_id).content.id)
          end
          
          @article.tags.each do |tag|
            entry.category(:term => tag.name)
          end
          
          if @article.entry.public_read == true
            entry.tag!('gd:visibility', "public")
          else 
            entry.tag!('gd:visibility', "private")
          end

          entry.author do |author|
            author.name("SIR")
          end
  
end
