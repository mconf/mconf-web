resource_type ||= model_class.name.underscore
collection    ||= __send__(resource_type.pluralize)

atom_feed('xmlns:app' => 'http://www.w3.org/2007/app',
          :root_url => polymorphic_url([ path_container, resource_type.classify.constantize.new ])) do |feed|

  feed.title(sanitize(title))

  feed.subtitle(:type => "xhtml") do
    feed.div(sanitize(path_container.description), :xmlns => "http://www.w3.org/1999/xhtml")
  end if path_container.try(:description).present?

  feed.updated(collection.any? && collection.first.updated_at || Time.now)

  collection.each do |content|
    feed.entry(content, :url => polymorphic_url(content)) do |entry|
      render :partial => "#{ resource_type.pluralize }/#{ resource_type }",
             :object => content,
             :locals => { :entry => entry }
    end
  end
end
