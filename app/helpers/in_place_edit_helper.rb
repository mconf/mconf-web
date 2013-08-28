# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module InPlaceEditHelper

  def in_place_edit_indicators(error_msg="", success_msg="")
    s1 = content_tag :span, "", :class => "in-place-edit-indicator in-progress"
    s2 = content_tag :span, "error", :class => "in-place-edit-indicator error" do
      content_tag(:i, "", :class => "icon-remove") +
        content_tag(:span, " #{error_msg}")
    end
    s3 = content_tag :span, "success", :class => "in-place-edit-indicator success" do
      content_tag(:i, "", :class => "icon-ok") +
        content_tag(:span, " #{success_msg}")
    end
    s1 + s2 + s3
  end

end
