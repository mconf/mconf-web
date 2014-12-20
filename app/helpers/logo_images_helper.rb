module LogoImagesHelper

  # Helper method to render an avatar or logo for a resource.
  # Requires the hash options to have a :size in it with the size of the logo
  # requested (e.g. options[:size]="128")
  def logo_image(resource, options={})
    if resource.is_a?(User)
      model_type = :user
    elsif resource.is_a?(Space)
      model_type = :space
    elsif mod_enabled?('events') && resource.is_a?(MwebEvents::Event)
      model_type = :event
    end

    if resource.respond_to?(:logo_image) && resource.logo_image.present?

      # Check if the version requested is among the existent versions, otherwise
      # return an empty logo
      version_name = "logo#{options[:size]}".to_sym
      versions = resource.logo_image.versions.keys
      if versions.include?(version_name)

        # For newer versions, we check if the file exists, otherwise return a version
        # we know exists
        if version_name == :logo300
          version_name = :logo128 unless resource.logo_image.send(version_name).file.exists?
        elsif version_name == :logo336x256
          version_name = :logo168x128 unless resource.logo_image.send(version_name).file.exists?
        end

        image_tag(resource.logo_image_url(version_name), options)
      else
        empty_logo_image(model_type, options)
      end
    else
      empty_logo_image(model_type, options)
    end
  end

  def empty_logo_image(resource, options={})
    case resource
    when :user
      path_no_image = "default_logos/" + options[:size] + "/user.png"
    when :space
      path_no_image = "default_logos/" + options[:size] + "/space.png"
    when :event
      path_no_image = "default_logos/" + options[:size] + "/event.png"
    end
    cls = "#{options[:class]} empty-logo"
    image_tag(path_no_image, class: cls, title: options[:title])
  end

  def link_logo_image(resource, options={})
    options_img = options.clone
    options[:url] ||= resource # url defaults to the resource's show
    link_to options[:url], :class => options[:class], :id => options[:id] do
      logo_image(resource, options_img)
    end
  end

  def logo_image_removed(options={})
    options[:class] = options.has_key?(:class) ? "#{options[:class]} logo logo-removed" : 'logo logo-removed'
    image_tag("icons/image_removed.png", :class => options[:class], :title => options[:title], :size => options[:size])
  end

end
