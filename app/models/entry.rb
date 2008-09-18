require "#{RAILS_ROOT}/vendor/plugins/cmsplugin/app/models/entry"
class Entry
  acts_as_tree :order => "title"

before_destroy { |entry| entry.children.map { |entry_children|  entry_children.content.destroy}}

after_create {|entry|if entry.parent_id != nil
 entry.parent.update_attribute(:updated_at , Time.now)
 end
}

after_update { |entry| entry.children.map {|entry_children| entry_children.update_attribute(:public_read, entry.public_read) } }
end
