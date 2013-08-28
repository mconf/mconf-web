module LogoImagesHelper

  def logo_image(resource, options = {})
    if resource.is_a?(User)
      path_no_image = "models/" + options[:size]  + "/user.png"
    elsif resource.is_a?(Space)
      size = options[:size].partition('x').last
      size = "64" if size == "60"
      path_no_image = "models/" + size  + "/space.png"
    end
    size = ("logo" + options[:size]).to_sym
    resource.logo_image.present? ? image_tag(resource.logo_image_url(size), options) : image_tag(path_no_image, :class => options[:class], :title => options[:title])
  end

  def link_logo_image(resource, options = {})
    link_to logo_image(resource, options), options[:url], :class => options[:class], :id => options[:id]
  end

end
