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
      # e.g. 'MwebEvents::Event' to 'mweb_events_event'
      cls = cls.underscore.gsub(/\//, '_')
      t("activities.#{cls}.deleted")
    else
      case trackable
      when Space then link_to(trackable.name, space_path(trackable))
      when Post  then link_to(trackable.post_title, space_post_path(trackable.space, trackable))
      when News  then link_to(trackable.title, space_news_path(trackable.space, trackable))
      when Attachment then link_to(trackable.title, space_event_path(trackable.space, trackable))
      when BigbluebuttonMeeting
        if trackable.room.owner_type == 'User'
          link_to(trackable.room.owner.full_name, user_path(trackable.room.owner))
        elsif trackable.room.owner_type == 'Space'
          link_to(trackable.room.owner.name, space_path(trackable.room.owner))
        end
      when JoinRequest
        if trackable.group_type == 'Space'
          link_to(trackable.group.name, space_path(trackable.group))
        end
      else
        if mod_enabled?('events')
          case trackable
          when MwebEvents::Event then link_to(trackable.name, mweb_events.event_path(trackable))
          when MwebEvents::Participant then link_to(trackable.event.name, mweb_events.event_path(trackable.event))
          end
        end
      end
    end
  end

  # Gets the route to user resource from its id
  def user_path_from_id id
    user = User.find_by_id(id)
    if user.nil?
      nil
    else
      user_path(user.to_param)
    end
  end

end
