# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class PathHelpers

  def self.images_full_path
    File.join(Rails.root.to_s, "app", "assets", "images")
  end

  def self.assets_full_path
    File.join(Rails.root.to_s, "app", "assets")
  end

end
