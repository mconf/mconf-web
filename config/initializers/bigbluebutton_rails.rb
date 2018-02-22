# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

BigbluebuttonRails.configure do |config|
  config.guest_support = true
  config.playback_url_authentication = Rails.application.config.playback_url_authentication
  config.playback_iframe = Rails.application.config.playback_iframe

  # Set the invitation URL to the full URL of the room
  config.get_invitation_url = Proc.new do |room|
    host = Site.current.domain_with_protocol
    Rails.application.routes.url_helpers.join_webconf_url(room, host: host)
  end

  # Add custom metadata to all create calls
  config.get_create_options = Proc.new do |room, user|
    host = Site.current.domain_with_protocol

    opts = {
      "meta_mconfweb-url": Rails.application.routes.url_helpers.root_url(host: host),
      "meta_mconfweb-room-type": room.try(:owner).try(:class).try(:name)
    }

    if Rails.application.config.per_user_record_permissions
      opts[:record] = true
    else
      ability = Abilities.ability_for(user)
      if user.present?
        reason = user.try(:cant_record_reason, room)
      else
        reason = I18n.t('users.cant_record_reason.user_cannot_record')
      end

      opts[:record] = ability.can?(:record_meeting, room)
      opts[:"meta_mconf-live-wont-record-message"] = reason if reason.present?
    end

    opts
  end

  # Add custom metadata join calls
  config.get_join_options = Proc.new do |room, user|
    if Rails.application.config.per_user_record_permissions
      ability = Abilities.ability_for(user)

      opts = {
        "userdata-record": ability.can?(:record_meeting, room)
      }

      if user.present?
        reason = user.try(:cant_record_reason, room)
      else
        reason = I18n.t('users.cant_record_reason.user_cannot_record')
      end
      opts[:"userdata-disabled_record_reason"] = reason if reason.present?

      opts
    else
      {}
    end
  end
end

Rails.application.config.to_prepare do

  BigbluebuttonRoom.class_eval do

    # prevent duplicates and rooms with blacklisted names
    validates :slug, blacklist: true, room_slug_uniqueness: true

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

    def short_path
      Rails.application.routes.url_helpers.join_webconf_path(self)
    end
  end

  BigbluebuttonMeeting.class_eval do
    # Fetches also the recordings associated with the meetings. Returns meetings even if they do not
    # have a recording.
    scope :with_or_without_recording, -> {
      joins("LEFT JOIN bigbluebutton_recordings ON bigbluebutton_meetings.id = bigbluebutton_recordings.meeting_id")

    }
    scope :with_recording, -> {
      joins("RIGHT JOIN bigbluebutton_recordings ON bigbluebutton_meetings.id = bigbluebutton_recordings.meeting_id")
    }

    def duration
      if self.finish_time.present?
        self.finish_time - self.create_time
      else
        nil
      end
    end
  end

  BigbluebuttonRecording.class_eval do
    # Search recordings based on a list of words
    scope :search_by_terms, -> (words) {
      query = joins(:room).includes(:room)

      if words.present?
        words ||= []
        words = [words] unless words.is_a?(Array)
        query_strs = []
        query_params = []
        query_orders = []

        words.reject(&:blank?).each do |word|
          str  = "bigbluebutton_recordings.name LIKE ? OR bigbluebutton_recordings.description LIKE ?"
          str += " OR bigbluebutton_recordings.recordid LIKE ? OR bigbluebutton_rooms.name LIKE ?"
          query_strs << str
          query_params += ["%#{word}%", "%#{word}%"]
          query_params += ["%#{word}%", "%#{word}%"]
          query_orders += [
            "CASE WHEN bigbluebutton_recordings.name LIKE '%#{word}%' THEN 1 ELSE 0 END + \
             CASE WHEN bigbluebutton_recordings.description LIKE '%#{word}%' THEN 1 ELSE 0 END + \
             CASE WHEN bigbluebutton_recordings.recordid LIKE '%#{word}%' THEN 1 ELSE 0 END + \
             CASE WHEN bigbluebutton_rooms.name LIKE '%#{word}%' THEN 1 ELSE 0 END"
          ]
        end
        query = query.where(query_strs.join(' OR '), *query_params.flatten).order(query_orders.join(' + ') + " DESC")

      end

      query
    }

    # The default ordering for search methods
    scope :search_order, -> {
      order("bigbluebutton_recordings.start_time DESC")
    }

    # Filters a query to return only recordings that have at least one playback format
    scope :has_playback, -> {
      where(id: BigbluebuttonPlaybackFormat.select(:recording_id).distinct)
    }

    # Filters a query to return only recordings that have no playback format
    scope :no_playback, -> {
      where.not(id: BigbluebuttonPlaybackFormat.select(:recording_id).distinct)
    }

    def duration
      if self.end_time.present?
        self.end_time - self.start_time
      else
        nil
      end
    end
  end

  BigbluebuttonMeeting.instance_eval do
    include PublicActivity::Model

    tracked only: [:create], owner: :room,
      recipient: -> (ctrl, model) { model.room.owner },
      params: {
        creator_id: -> (ctrl, model) {
          model.try(:creator_id)
        },
      creator_username: -> (ctrl, model) {
        id = model.try(:creator_id)
        user = User.find_by(id: id)
        user.try(:username)
      }
    }

    scope :newest, -> (count=0) {
      ordered = order("create_time DESC")
      if count > 0
        ordered.first(count)
      else
        ordered
      end
    }
  end

  BigbluebuttonServer.instance_eval do

    # When the URL of the default server changes, change the URL of all institution servers.
    after_update if: :url_changed? do
      if BigbluebuttonServer.default.id == self.id
        BigbluebuttonServer.where.not(id: self.id).update_all(url: self.url)
      end
    end

  end
end
