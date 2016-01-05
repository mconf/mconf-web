# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

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
# * (recipient_id, recipient_type) recipient: Tipically used for user responsible for the activity and who should see it in his activity stream
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
#
# === List of recent activity types
# There are several types of activities created by the application. This is a list with all of the
# types used, indexed by `key`.
# Note: to get the full list of keys, go to a well populated website and run
# `RecentActivity.pluck(:key).uniq.sort`.
#
# * `attachment.create`:
#   When an `Attachment` is created, uploaded to the website.
#   Created by: `Attachment`.
#
# * `attachment.destroy`:
#   When an `Attachment` is destroyed, removed from the website.
#   Created by: `Attachment`.
#
# * `bigbluebutton_meeting.create`:
#   A meeting was created.
#   Created by `BigbluebuttonMeeting`, code at `config/initializers/bigbluebutton_rails`.
#
# * `event.create`:
#   An event was created.
#   Created by `EventsController`, code at `lib/controllers/events_controller`.
#
# * `event.update`:
#   An event was updated.
#   Created by `EventsController`, code at `lib/controllers/events_controller`.
#
# * `join_request.invite`:
#   Somebody sent a invitation to someone join a space.
#   Created by `JoinRequest`.
#
# * `join_request.request`:
#   Somebody sent a request to join a space.
#   Created by `JoinRequest`.
#
# * `ldap.user.created`:
#   When a `User` was created for someone that signed in via LDAP.
#   Created by: `Mconf::LDAP`.
#
# * `participant.create`:
#   Someone registered to participante in an event.
#   Created by `ParticipantsController`, code at `lib/controllers/participants_controller`.
#
# * `post.create`:
#   A post was created.
#   Created by `PostsController`.
#
# * `post.reply`:
#   Somebody replied to a post.
#   Created by `PostsController`.
#
# * `post.update`:
#   A post was updated.
#   Created by `PostsController`.
#
# * `shibboleth.user.created`:
#   When a `User` was created for someone that signed in via Shibboleth.
#   Created by: `Mconf::Shibboleth`.
#
# * `space.accept`:
#   Somebody accepted an invitation to join a space.
#   Created by `JoinRequestsController`.
#
# * `space.create`:
#   A space was created.
#   Created by `SpacesController`.
#
# * `space.decline`:
#   Somebody declined an invitation to join a space.
#   Created by `JoinRequestsController`.
#
# * `space.leave`:
#   Somebody left a space.
#   Created by `SpacesController`.
#
# * `space.update`:
#   A space was updated.
#   Created by `SpacesController`.
#
# * `user.approved`:
#   When a was approved.
#   Created by: `User`, in a method that's called from `UsersController`.
#
# * `user.created`:
#   When a `User` was created after registering himself/herself.
#   Created by: `User`.
#
# * `user.created_by_admin`:
#   When a `User` was created after being registered by an admin.
#   Created by: `User`.
#
class RecentActivity < PublicActivity::Activity
  # Used for home page and user page pagination
  self.per_page = 10

  # Returns a relation with all the activity related to a user: activities in his spaces
  # and web conference rooms.
  # * +user+ - the user which activities will be returned
  # * +reject_keys+ - an array of keys to reject when querying. Keys are the strings that identify
  #   the recent activity, e.g. "space.leave".
  # * +in_spaces+ - limit the returned activity to spaces present in this array of spaces. If `nil`
  #   will not limit. If empty, will limit everything.
  def self.user_activity(user, reject_keys=[], in_spaces=nil)
    user_room = user.bigbluebutton_room
    spaces = user.spaces

    # if there's an array in 'in_space', limit the activity to these spaces plus
    # any other public space
    # we filter public spaces here by default and not outside to improve performance
    unless in_spaces.nil?
      spaces = spaces.where("spaces.id IN (?) OR spaces.public = ?", in_spaces.map(&:id), true)
    end

    space_rooms = spaces.map{ |s| s.bigbluebutton_room.id }

    # some types of activities we ignore by default
    reject_keys += ["user.created", "shibboleth.user.created", "ldap.user.created", "user.approved"]

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
  def self.user_public_activity user, opt={}

    # Filter activities done by user_id
    user_activity(user, ["space.decline"], opt[:in_spaces]).where(recipient_id: user.id)
  end
end
