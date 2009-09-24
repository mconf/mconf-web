Factory.define :post do |p| 
  p.sequence(:title) { |n| "Post #{ n }" }
  p.text "test"
  p.created_at { Time.now }
  p.updated_at { Time.now }
  #  p.reader_id
  #  p.space_id
  #  p.author_id
  #  p.author_type
  #  p.parent_id
  #  p.event_id
  #  p.guid
  #  p.spam
end


Factory.define :post_empty_title, :parent => :post do |p|
  p.title "";
end

Factory.define :post_empty_text, :parent => :post do |p|
  p.text "";
end

Factory.define :post_spam, :parent => :post do |p|
  p.spam true;
end

#Factory.define :superuser, :parent => :user do |u|
#  p.superuser true
#end