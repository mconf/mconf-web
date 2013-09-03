# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module PublicActivitiesHelper

  def activity_translate key, options={}
    t("activities.#{key}_html", options)
  end

  def link_to_trackable trackable, cls
    if trackable.nil?
      t("activities.#{cls.downcase}.deleted")
    else
      case trackable
        when Space then link_to(trackable.name, space_path(trackable))
        when Event then link_to(trackable.title, space_event_path(trackable.space, trackable))
        when Post  then link_to(trackable.title, space_post_path(trackable.space, trackable))
        when News  then link_to(trackable.title, space_news_path(trackable.space, trackable))
        when Attachment then link_to(trackable.post_title, space_event_path(trackable.space, trackable))
      end
    end
  end

end
