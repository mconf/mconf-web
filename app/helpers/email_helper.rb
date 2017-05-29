# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module EmailHelper

  # Attaches an image to an email and puts an `image_tag` with it.
  # Use this in email views as a replacement for `image_tag`.
  def email_image_tag(image, **options)
    if image.match(/\//)
      path = image
    else
      path = "app/assets/images/#{image}"
    end
    attachments[image] = File.read(Rails.root.join(path))
    image_tag attachments[image].url, **options
  end

end
