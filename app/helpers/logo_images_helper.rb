# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'digest/sha1'

def image_url(path)
  "#{root_url}/#{image_path(path)}"
end

module LogoImagesHelper

  # Helper method to render an avatar or logo for a resource.
  # Requires the hash options to have a :size in it with the size of the logo
  # requested (e.g. options[:size]="128")
  def logo_image(resource, options={})
    options[:size] = validate_logo_size(options[:size])

    if resource.is_a?(User)
      model_type = :user
    elsif resource.is_a?(Space)
      model_type = :space
    elsif mod_enabled?('events') && resource.is_a?(Event)
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
        logo_initials(resource, options)
      end

    # Try a gravatar image if we have a confirmed user
    elsif model_type == :user && current_site.use_gravatar? && resource.confirmed?
      grav_options = {}
      grav_options[:size] = options[:size]
      grav_options[:default] = "mm"
      grav_options[:secure] = true
      options[:alt] = resource.name
      image_tag(GravatarImageTag.gravatar_url(resource.email, grav_options), options)

    else
      logo_initials(resource, options)
    end
  end

  def logo_initials_class(seed)
    i = Digest::SHA1.hexdigest(seed).to_i(16)
    i = (i % 9) + 1
    #i = (seed/1000) % 10
    "logo-initials-#{i}"
  end

  def logo_initials(resource, options={})
    logo_initials_cls = logo_initials_class(resource.name)
    cls = "#{options[:class]} logo-initials #{logo_initials_cls}".strip
    content_tag :div, resource.initials[0..1].upcase, class: cls, title: options[:title]
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

  # Renders the controls to upload a logo for a space or a user's avatar
  def upload_logo_controls(resource)
    path = if resource.is_a?(User)
             update_logo_user_path(resource, format: :json)
           elsif resource.is_a?(Space)
             update_logo_space_path(resource, format: :json)
           end
    attrs = {
      class: 'file-uploader file-uploader-logo',
      'data-endpoint': path,
      'data-accept': supported_image_formats.join(','),
      'data-max-size': max_upload_size
    }
    content_tag :div, nil, attrs
  end

  # Renders the controls to upload an attachment in a space
  def upload_attachment_controls(resource)
    path = if resource.is_a?(Space)
             space_attachments_path(resource, format: :json)
           end
    attrs = {
      class: 'file-uploader file-uploader-attachment',
      'data-endpoint': path,
      'data-max-size': max_upload_size
    }
    content_tag :div, nil, attrs
  end
end
