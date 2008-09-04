require "#{RAILS_ROOT}/vendor/plugins/cmsplugin/app/models/post"
class Post
  acts_as_tree :order => "title"
before_destroy { |post| post.children.map { |post_children|  post_children.content.destroy}}
end
