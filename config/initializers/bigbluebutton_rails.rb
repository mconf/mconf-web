# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

Rails.application.config.to_prepare do

  # Monkey-patches to add support for guest users in bigbluebutton_rails.
  # TODO: This is not standard in BBB yet, so this should be temporary and might
  #       be moved to bigbluebutton_rails in the future.
  BigbluebuttonRoom.instance_eval do
    @guest_support = true
    class << self; attr_reader :guest_support; end
  end
  BigbluebuttonRoom.class_eval do
    # Copy of the default Bigbluebutton#join_url with support to :guest
    def join_url(username, role, key=nil, options={})
      require_server

      case role
      when :moderator
        r = self.server.api.join_meeting_url(self.meetingid, username, self.moderator_api_password, options)
      when :attendee
        r = self.server.api.join_meeting_url(self.meetingid, username, self.attendee_api_password, options)
      when :guest
        params = { :guest => true }.merge(options)
        r = self.server.api.join_meeting_url(self.meetingid, username, self.attendee_api_password, params)
      else
        r = self.server.api.join_meeting_url(self.meetingid, username, map_key_to_internal_password(key), options)
      end

      r.strip! unless r.nil?
      r
    end

    # Returns whether the `user` created the current meeting on this room
    # or not. Has to be called after a `fetch_meeting_info`, otherwise will always
    # return false.
    def user_created_meeting?(user)
      meeting = get_current_meeting()
      unless meeting.nil?
        meeting.created_by?(user)
      else
        false
      end
    end

    # Currently room is public only if belonging to a public space
    def public?
      owner_type == "Space" && Space.where(:id => owner_id, :public => true).present?
    end

    def invitation_url
      Rails.application.routes.url_helpers.join_webconf_url(self, host: Site.current.domain)
    end
  end

  BigbluebuttonServer.instance_eval do

    # The server used on Mconf-Web is always the first one. We add this method
    # to wrap it and make it easier to change in the future.
    def default
      self.first
    end

  end

  BigbluebuttonMeeting.instance_eval do
    include PublicActivity::Common
  end

  BigbluebuttonMeeting.class_eval do
    after_create {
      self.create_activity :create, :owner => self.room unless self.errors.any?
    }
  end

end
