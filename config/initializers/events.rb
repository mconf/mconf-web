# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

Rails.application.config.to_prepare do
  Leaflet.tile_layer = "http://b.tile.openstreetmap.org/{z}/{x}/{y}.png"
  Leaflet.attribution = " \u00A9 OpenStreetMap contrib. <a href=\"http://creativecommons.org/licenses/by-sa/2.0/\">CC-BY-SA 2.0</a>"
  Leaflet.max_zoom = 15
end
