require "#{ RAILS_ROOT }/vendor/plugins/cmsplugin/app/models/tag"

class Tag
  def self.cloud(args = {})
    find(:all, :select => 'tags.* ,count(*) as popularity',
    :limit => args[:limit] || 30,
    :joins => "JOIN taggings ON taggings.tag_id = tags.id",
    :conditions => args[:conditions],
    :group => "taggings.tag_id",
    :order => "id")
  end
end
