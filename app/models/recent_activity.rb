# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.
#
# -------
# RecentActivity is a very flexible class which links models to activities which
# happen to pertrain those models. For example it is used to store when an user
# joins a space or when someone creates a new event.
#
# === Called from
# * Called from recent activity views in the home page and user page
# * Called from notifications via email in workers
#
# === Attributes
# Activities have many attributes and some are polymorphic, here's a quick rundown
# of how it looks like most of the time:
#
# * (trackable_id, trackable_type) trackable: The model to which the activity pertrains
# * (owner_id, owner_type) owner: Another model which is linked as owner of the activity. Typically this is the user which performed said activity.
# * (recipient_id, recipient_type) recipient: Not used in any model for now.
# * key: A string indicating the trackable model plus the action which happened (e.g. "space.join").
# * notified: A boolean informing whether the activity has already been notified to the user (usually this is done by a worker in background).
# * parameters: Extra data about the activity which can be used to avoid extra database queries or store volatile data which may disappear or change
#   in the future (e.g. store the name of a space when the name changes).
#
# === Example of a valid activity model
# Ommiting active record and unused fields
#    <RecentActivity
#       id: 374,
#       trackable_id: 6, trackable_type: "JoinRequest",
#       owner_id: 3, owner_type: "Space",
#       key: "join_request.invite",
#       parameters:
#         {:candidate_id=>7,
#          :introducer=>"Emily Perez", :introducer_id=>3,
#          :username=>"Randy Lawrence"},
#       notified: nil>

class RecentActivity < PublicActivity::Activity
  # Used for home page and user page pagination
  self.per_page = 10

  # Returns a relation with all the activity related to a user: activities in his spaces
  # and web conference rooms.
  # * +user+ - the user which activities will be returned
  # * +reject_keys+ - an array of keys to reject when querying. Keys are the strings that identify
  #   the recent activity, e.g. "space.leave".
  def self.user_activity(user, reject_keys=[])
    user_room = user.bigbluebutton_room
    spaces = user.spaces
    space_rooms = spaces.map{ |s| s.bigbluebutton_room.id }

    t = RecentActivity.arel_table
    in_spaces = t[:owner_id].in(spaces.pluck(:id)).and(t[:owner_type].eq('Space'))
    in_spaces_as_trackable = t[:trackable_id].in(spaces.pluck(:id)).and(t[:trackable_type].eq('Space'))
    in_room = t[:owner_id].in(user_room.id).and(t[:owner_type].eq('BigbluebuttonRoom'))
    in_space_rooms = t[:owner_id].in(space_rooms).and(t[:owner_type].eq('BigbluebuttonRoom'))

    activities = RecentActivity.where(in_spaces.or(in_spaces_as_trackable).or(in_room).or(in_space_rooms))
    for key in reject_keys
      activities = activities.where("activities.key != ?", key)
    end
    activities
  end

  # All activities that are public and should be visible for a user
  # * +user+ - the user which activities will be returned
  def self.user_public_activity user
    # Filter activities done by user_id
    activities = user_activity(user, ["space.decline"]).select do |act|
      act.parameters[:user_id] == user.id
    end

    # return a relation back
    where id: activities.map(&:id)
  end
end
