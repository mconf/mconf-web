atom_feed({'xmlns:gd' => 'http://schemas.google.com/g/2005',
  'xmlns:sir' => 'http://sir.dit.upm.es/schema'}) do |feed|
  feed.title("#{ t('space.other') } - #{ t(:vcc) }")
  feed.updated(@spaces.any? && @spaces.first.updated_at || Time.now)

  @spaces.each do |space|
    feed.entry(space) do |entry|
      entry.link(:href => logo_image_url(space, :size => 'h64'), :rel => :icon, :size => '84x64')
      entry.title(sanitize(space.name))
      entry.summary(sanitize(space.description), :type => 'html')
      entry.tag!('gd:deleted', space.deleted)
      entry.tag!('sir:parent_id', space.parent_id)
      entry.tag!('gd:visibility', (space.public? ? "public" : "private"))

      space.actors(:role => "Admin").each do |admin|
        entry.author do |author|
          author.name(admin.name)
        end
      end
    end
  end
end
