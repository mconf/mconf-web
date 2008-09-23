    atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005'}) do |feed|
      feed.title("Posts")
      feed.updated((@articles.first.content_entries.first.updated_at unless @articles.first==nil))

      for article in @articles
        feed.entry(article, :url => space_article_path(@space, article)) do |entry|
          entry.title(article.name)
          entry.summary(article.description)
          entry.updated((article.content_entries.first.updated_at.to_datetime))
          

          entry.author do |author|
            author.name("SIR")
          end
        end
      end
    end
