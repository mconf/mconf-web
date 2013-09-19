module LogoImagesHelper

  def logo_image(resource, options = {})
    if resource.is_a?(User)
      options[:size] = '128' if options[:size] > '32'
      path_no_image = "default_logos/" + options[:size] + "/user.png"
    elsif resource.is_a?(Space)
      path_no_image = "default_logos/" + options[:size] + "/space.png"
    end
    size = ("logo" + options[:size]).to_sym
    resource.logo_image.present? ?
      image_tag(resource.logo_image_url(size), options) :
      image_tag(path_no_image, :class => options[:class], :title => options[:title])
  end

  def link_logo_image(resource, options = {})
    optionsImg = options.clone
    options[:url] ||= resource # url defaults to the resource's show
    link_to options[:url], :class => options[:class], :id => options[:id] do
      logo_image(resource, optionsImg)
    end
  end

end
