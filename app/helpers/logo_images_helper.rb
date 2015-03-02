module LogoImagesHelper

  # TODO: If `options[:size]` is wrong, the image will not be found and the application
  #   will crash in production. This method should check this option to prevent this error.
  def logo_image(resource, options={})
    options[:size] = validate_logo_size(options[:size])

    if resource.is_a?(User)
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
    options[:size] = validate_logo_size(options[:size])

    case resource
    when :user
      path_no_image = "default_logos/" + options[:size] + "/user.png"
    when :space
      path_no_image = "default_logos/" + options[:size] + "/space.png"
    when :event
      path_no_image = "default_logos/" + options[:size] + "/event.png"
    end
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

  # Makes sure we only create logos with a size
  # recognized by the application
  def validate_logo_size(size)
    valid_sizes = ['32', '84x64', '128', '168x128', '300', '336x256']

    if valid_sizes.include?(size)
      size
    else
      '128'
    end
  end

end
