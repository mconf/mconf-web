require "#{RAILS_ROOT}/vendor/plugins/cmsplugin/app/models/entry"
class Entry
  acts_as_tree :order => "title"
before_destroy { |entry| entry.children.map { |entry_children|  entry_children.content.destroy}}
end
