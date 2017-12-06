# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

BigbluebuttonRails.configure do |config|
  config.guest_support = true

  # Set the invitation URL to the full URL of the room
  config.get_invitation_url = Proc.new do |room|
    host = Site.current.domain_with_protocol
    Rails.application.routes.url_helpers.join_webconf_url(room, host: host)
  end

  # Add custom metadata to all create calls
  config.get_create_options = Proc.new do |room, user|
    host = Site.current.domain_with_protocol
    ability = Abilities.ability_for(user)

    {
      "meta_mconfweb-url" => Rails.application.routes.url_helpers.root_url(host: host),
      "meta_mconfweb-room-type" => room.try(:owner).try(:class).try(:name),
      record: ability.can?(:record_meeting, room)
    }
  end
end

Rails.application.config.to_prepare do

  BigbluebuttonRoom.class_eval do

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
  end

  BigbluebuttonServer.instance_eval do

    # When the URL of the default server changes, change the URL of all institution servers.
    after_update if: :url_changed? do
      if BigbluebuttonServer.default.id == self.id
        BigbluebuttonServer.where.not(id: self.id).update_all(url: self.url)
      end
    end

  end

  BigbluebuttonRecording.instance_eval do

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
  end
end
