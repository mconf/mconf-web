# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Abilities

  class MemberAbility < BaseAbility
    def register_abilities(user)
      abilities_for_bigbluebutton_rails(user)

      # Users
      can [:index, :show, :fellows, :current, :select], User
      can [:edit, :update, :disable], User, id: user.id
      can [:update_password], User do |target_user|
        user == target_user &&
          (Site.current.local_auth_enabled? && !target_user.no_local_auth?)
      end

      # User profiles
      # Visible according to options selected by the user, editable by their owners
      # Note: For the private profile only, the public profile is always visible.
      #   Check for public profile with `can?(:show, user)` instead of `can?(:show, user.profile)`.
      can :index, Profile
      can :show, Profile do |profile|
        case profile.visibility
        when Profile::VISIBILITY.index(:everybody)
          true
        when Profile::VISIBILITY.index(:members)
          true
        when Profile::VISIBILITY.index(:public_fellows)
          profile.user.public_fellows.include?(user)
        when Profile::VISIBILITY.index(:private_fellows)
          profile.user.private_fellows.include?(user)
        when Profile::VISIBILITY.index(:nobody)
          false
        end
      end
      can [:show, :edit, :update, :update_logo], Profile, user_id: user.id
      # Some info is blocked if the user created by shib and auto update is enabled
      # in the site
      can [:update_full_name], Profile do |profile|
        profile.user == user &&
          (!profile.user.created_by_shib? || !Site.current.shib_update_users?)
      end

      # Spaces
      can :select, Space
      can [:create, :new], Space unless Site.current.forbid_user_space_creation?

      can [:index], Space
      can [:show, :webconference, :recordings, :index_event], Space, public: true
      can [:show, :webconference, :recordings, :index_event], Space do |space|
        space.users.include?(user)
      end
      can [:leave], Space do |space|
        space.users.include?(user) && !space.is_last_admin?(user)
      end

      # Only the admin can disable or update information on a space
      # Only global admins can destroy spaces
      can [:edit, :update, :update_logo, :user_permissions,
           :webconference_options, :disable, :edit_recording], Space do |space|
        space.admins.include?(user)
      end

      # Join Requests
      # TODO: make everything for events also

      # normal users can request membership
      # admins in a space can invite users
      can [:create, :new], JoinRequest

      # users that created a join request can do a few things over it
      can [:show, :decline], JoinRequest do |jr|
        jr.group.try(:is_a?, Space) && jr.try(:candidate) == user
      end

      # users can accept invitations they received, space admins can accept requests
      # made to that space.
      can :accept, JoinRequest do |jr|
        group = jr.group
        if group.try(:is_a?, Space)
          (jr.is_invite? && jr.try(:candidate) == user) ||
            (jr.is_request? && group.admins.include?(user))
        else
          false
        end
      end

      # space admins can list requests and invite new members
      can [:manage_join_requests], Space do |s|
        s.admins.include?(user)
      end

      # space admins can work with all join requests in the space
      can [:show, :create, :new, :decline], JoinRequest do |jr|
        group = jr.group
        group.try(:is_a?, Space) && group.admins.include?(user)
      end

      # Posts
      # TODO: maybe space admins should be able to alter posts
      can :index, Post # restricted through Space
      can :show, Post, space: { public: true }
      can [:show, :create, :new, :reply_post], Post do |post|
        post.space.users.include?(user)
      end
      can [:show, :reply_post, :edit, :update, :destroy], Post, author_id: user.id

      # Attachments
      can :index, Attachment # restricted through Space
      can :manage, Attachment do |attach|
        attach.space.admins.include?(user)
      end
      can [:show, :create, :new], Attachment do |attach|
        attach.space.users.include?(user)
      end
      can [:destroy], Attachment do |attach|
        attach.space.users.include?(user) &&
        attach.author_id == user.id
      end
      can [:show], Attachment, space: { public: true }

      # Permissions
      # Only space admins can update user roles/permissions
      can :index, Permission # restricted through Space
      can [:show, :edit], Permission do |perm|
        case perm.subject_type
        when "Space"
          perm.subject.admins.include?(user)
        else
          false
        end
      end
      can [:update, :destroy], Permission do |perm|
        case perm.subject_type
        when "Space"
          perm.subject.admins.include?(user) &&
            !perm.subject.is_last_admin?(perm.user)
        else
          false
        end
      end

      permissions_for_events(user)

      restrict_access_to_disabled_resources(user)
      restrict_access_to_unapproved_resources(user)
    end

    private

    def permissions_for_events(user)
      can [:select, :show, :index, :create, :new], Event

      # users can't create events in a space they don't belong to
      cannot [:create, :new], Event do |event|
        if event.owner_type == 'Space'
          owner = Space.with_disabled.find(event.owner_id)
          !owner.users.include?(user)
        end
      end

      can [:edit, :update, :destroy, :invite, :send_invitation], Event do |e|
        event_can_be_managed_by(e, user)
      end

      can :register, Event do |e|
        # not the owner and the event is public or in a space the user has access to
        Participant.where(owner_id: user.id, event_id: e.id).empty? &&
          (e.public || (e.owner_type == 'Space' && e.owner.users.include?(user)))
      end

      can :destroy, Participant do |p|
        p.owner == user
      end

      can [:show, :edit, :update, :destroy], Participant do |p|
        event_can_be_managed_by(p.event, user)
      end

      can [:index, :create, :new], Participant
    end

    def event_can_be_managed_by(event, user)
      case event.owner_type
      when 'User' then
        event.owner_id == user.id
      when 'Space' then
        organizer = user.permissions.where(
          subject_type: 'Event', role_id: Role.find_by_name('Organizer'), subject_id: event.id
        ).any?
        space_admin = user.permissions.where(
          subject_type: 'Space', role_id: Role.find_by_name('Admin'), subject_id: event.owner_id
        ).any?
        organizer || space_admin
      end
    end

    # Abilities for the resources from BigbluebuttonRails.
    # Not everything is done here, some authorization steps are done by the gem
    # BigbluebuttonRails itself.
    # These actions have a difference from most of the other resources: most of them are only
    # accessible by admins, including standard actions such as `:show`, `:edit`, and `:index`.
    # However, normal users also have access to limited version of these actions, such as a page
    # to edit just a few attributes of a room or a recording. The methods for these actions are
    # in controllers other than the standard controllers for these resources (e.g.
    # BigbluebuttonRoomsController) and are named differently to differ than from the standard
    # actions (e.g. `:space_show` is a limited version of `:show` for rooms in spaces).
    def abilities_for_bigbluebutton_rails(user)

      # Can do the actions below if he's the owner or if he belongs to the space (with any role)
      # that owns the room.
      # `:create_meeting` is a custom name, not an action that exists in the controller
      can [:create_meeting, :fetch_recordings,
           :invitation, :send_invitation], BigbluebuttonRoom do |room|
        user_is_owner_or_belongs_to_rooms_space(user, room)
      end

      # For user rooms only the owner can end meetings.
      # In spaces only the admins and the person that started the meeting can end it.
      can :end, BigbluebuttonRoom do |room|
        user_can_end_meeting(user, room)
      end

      # Users can recording meetings in their rooms, but only if they have the record flag set.
      # `:record_meeting` is a custom name, not an action that exists in the controller
      can :record_meeting, BigbluebuttonRoom do |room|
        user.can_record && user_is_owner_or_belongs_to_rooms_space(user, room)
      end

      # Currently only user rooms can be updated
      # TODO: rooms in spaces should also be updatable, but for now they
      # are edited through the space
      can [:update], BigbluebuttonRoom do |room|
        room.owner_type == "User" && room.owner.id == user.id
      end

      # some actions in rooms should be accessible to any logged user
      # some of them will do the authorization themselves (e.g. permissions for :join
      # will change depending on the user and the target room)
      can [:invite, :invite_userid, :running, :join, :join_mobile], BigbluebuttonRoom

      # a user can play recordings of his own room or recordings of
      # rooms of either public spaces or spaces he's a member of
      can [:play], BigbluebuttonRecording do |recording|
        user_is_member_of_recordings_space(user, recording) ||
          recordings_space_is_public(recording) ||
          user_is_owner_of_recording(user, recording)
      end

      # a user can edit his recordings and recordings in spaces where he's an admin
      can [:update], BigbluebuttonRecording do |recording|
        user_is_owner_of_recording(user, recording) ||
          user_is_admin_of_recordings_space(user, recording)
      end

      # a user can see and edit his recordings
      can [:user_show, :user_edit], BigbluebuttonRecording do |recording|
        user_is_owner_of_recording(user, recording)
      end

      # admins can edit recordings in their spaces
      can [:space_edit], BigbluebuttonRecording do |recording|
        user_is_admin_of_recordings_space(user, recording)
      end

      # recordings can be viewed in spaces if the space is public or the user belongs to the space
      can [:space_show], BigbluebuttonRecording do |recording|
        user_is_member_of_recordings_space(user, recording) ||
          recordings_space_is_public(recording)
      end
    end

    # Whether `user` is the owner of `room` of belongs to the space that owns `room`.
    def user_is_owner_or_belongs_to_rooms_space(user, room)
      if (room.owner_type == "User" && room.owner.id == user.id)
        true
      elsif (room.owner_type == "Space")
        space = Space.find(room.owner.id)
        space.users.include?(user)
      else
        false
      end
    end

    # Whether `user` can end the meeting in `room`.
    def user_can_end_meeting(user, room)
      if (room.owner_type == "User" && room.owner.id == user.id)
        true
      elsif (room.owner_type == "Space")
        space = Space.find(room.owner.id)
        if space.admins.include?(user)
          true
        elsif room.user_created_meeting?(user)
          true
        else
          false
        end
      else
        false
      end
    end

    # Whether `user` owns the room that owns `recording`.
    def user_is_owner_of_recording(user, recording)
      response = false
      unless recording.room.nil?
        if recording.room.owner_type == "User" && recording.room.owner_id == user.id
          response = true
        end
      end
      response
    end

    # Whether the user is an admin of the space that owns the room that owns `recording`.
    def user_is_admin_of_recordings_space(user, recording)
      response = false
      unless recording.room.nil?
        if recording.room.owner_type == "Space"
          space = Space.find(recording.room.owner_id)
          response = space.admins.include?(user)
        end
      end
      response
    end

    # Whether the user is a member of the space that owns the room that owns `recording`.
    def user_is_member_of_recordings_space(user, recording)
      response = false
      unless recording.room.nil?
        if recording.room.owner_type == "Space"
          space = Space.find(recording.room.owner_id)
          response = space.users.include?(user)
        end
      end
      response
    end

    # Whether the space that owns the room that owns `recording` is public.
    def recordings_space_is_public(recording)
      recording.room.try(:public?)
    end

  end

end
