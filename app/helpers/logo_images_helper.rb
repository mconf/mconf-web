module LogoImagesHelper

  # TODO: If `options[:size]` is wrong, the image will not be found and the application
  #   will crash in production. This method should check this option to prevent this error.
  def logo_image(resource, options={})
    if resource.is_a?(User)
      options[:size] = '128' if options[:size] > '32'
      model_type = :user
    elsif resource.is_a?(Space)
      model_type = :space
    else
      if mod_enabled?('events') && resource.is_a?(MwebEvents::Event)
        model_type = :event
      end
    end
    size = ("logo" + options[:size]).to_sym
    (resource.respond_to?(:logo_image) && resource.logo_image.present?) ?
      image_tag(resource.logo_image_url(size), options) :
      empty_logo_image(model_type, options)
  end

  def empty_logo_image(resource, options={})
    case resource
    when :user
      options[:size] = '128' if options[:size] > '32'
      path_no_image = "default_logos/" + options[:size] + "/user.png"
    when :space
      path_no_image = "default_logos/" + options[:size] + "/space.png"
    when :event
      path_no_image = "default_logos/" + options[:size] + "/event.png"
    end
    size = ("logo" + options[:size]).to_sym
    image_tag(path_no_image, :class => options[:class], :title => options[:title])
  end

  def link_logo_image(resource, options={})
    optionsImg = options.clone
    options[:url] ||= resource # url defaults to the resource's show
    link_to options[:url], :class => options[:class], :id => options[:id] do
      logo_image(resource, optionsImg)
    end
  end

  def logo_image_removed(options={})
    options[:class] = options.has_key?(:class) ? "#{options[:class]} logo logo-removed" : 'logo logo-removed'
    image_tag("icons/image_removed.png", :class => options[:class], :title => options[:title], :size => options[:size])
  end

end
