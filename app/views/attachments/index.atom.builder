     atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005', 
    'xmlns:sir' => 'http://sir.dit.upm.es/schema', 'xmlns:thr' => 'http://purl.org/syndication/thread/1.0'}) do |feed|
      feed.title("Attachments")
      feed.updated((@attachments.first.content_entries.first.updated_at unless @attachments.first==nil))

      for attachment in @attachments
        feed.entry(attachment, :url => space_attachment_path(@space, attachment)) do |entry|
          entry.title(attachment.entry.title)
          entry.summary(attachment.entry.description)
          entry.link(:rel => "edit", :ref => formatted_space_attachment_path(@space, attachment, :atom))
          entry.content(:src => formatted_space_attachment_path(@space, attachment, :all))
          if attachment.entry.parent
          entry.tag!('thr:in-reply-to', :ref => "tag:"+request.host+",2005:"+attachment.entry.parent.class.to_s+"/"+
          attachment.entry.parent.id.to_s)
          end
          entry.tag!('sir:size', attachment.size)
          entry.tag!('sir:filename', attachment.filename)
          entry.tag!('sir:height', attachment.height)
          entry.tag!('sir:width', attachment.width)
          entry.tag!('sir:content_type', attachment.content_type)

          entry.author do |author|
            author.name("SIR")
          end
        end
      end
    end