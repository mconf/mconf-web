# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  def base_language_only
    yield if Locale.base?
  end

  def not_base_language
    yield unless Locale.base?
  end
  #this method is to create the tag_cloud in our views
  
def build_tag_cloud(tag_cloud, style_list)
max, min = 0, 0
tag_cloud.each do |tag|
max = tag.popularity.to_i if tag.popularity.to_i > max
min = tag.popularity.to_i if tag.popularity.to_i < min
end

divisor = ((max - min) / style_list.size) + 1

tag_cloud.each do |tag|
yield tag.name, style_list[(tag.popularity.to_i - min) / divisor]
end
end
def prueba
  
end
def tag_item_url(name)
  "/search_events?query=#{name}&commit=Search"
end
end
