# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Based on https://gist.github.com/3729390/

module Abilities

  def self.ability_for(user)
    if user and user.superuser?
      SuperUserAbility.new(user)
    elsif user and !user.anonymous?
      MemberAbility.new(user)
    else
      AnonymousAbility.new
    end
  end

  class BaseAbility
    include CanCan::Ability

    def initialize(user=nil)
      # remove the default aliases to remove the one that says:
      #   `alias_action :edit, :to => :update`
      # we have some models where the user should have access to :update but not
      # to :edit, and this alias was binding them together.
      clear_aliased_actions
      alias_action :index, :show, :to => :read
      alias_action :new, :to => :create

      register_abilities(user)
    end
  end


  class SuperUserAbility < BaseAbility
    # TODO: restrict a bit what superusers can do
    def register_abilities(user)
      can :manage, :all
    end
  end

  class MemberAbility < BaseAbility
    def register_abilities(user)
      abilities_for_bigbluebutton_rails(user)

      # Users
      # Disabled users are only visible to superusers
      can [:read, :fellows, :current, :select], User, :disabled => false
      can [:edit, :update, :destroy], User, :id => user.id, :disabled => false

      # User profiles
      # Visible according to options selected by the user, editable by their owners
      can :read, Profile do |profile|
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
      can [:read, :edit, :update], Profile, :user_id => user.id

      # Private messages
      can :create, PrivateMessage
      can :read, PrivateMessage do |message|
        [message.sender_id, message.receiver_id].include?(user.id)
      end
      can :destroy, PrivateMessage do |message|
        [message.sender_id, message.receiver_id].include?(user.id)
      end

      # Spaces
      can [:create, :select], Space
      can [:read, :webconference, :recordings], Space, :public => true
      can [:read, :webconference, :recordings, :leave], Space do |space|
        space.users.include?(user)
      end
      # Only the admin can destroy or update information on a space
      can [:destroy, :edit, :update, :user_permissions], Space do |space|
        space.admins.include?(user)
      end

      # Join Requests
      # users can create unless they are already in the target space
      # TODO: make this for events also
      can :create, JoinRequest do |jr|
        group = jr.group
        if !group.nil? and group.is_a?(Space)
          !group.users.include?(user)
        else
          false
        end
      end
      # space admins and users that created the join request can destroy it
      # TODO: make this for events also
      can :destroy, JoinRequest do |jr|
        group = jr.group
        if !group.nil? and group.is_a?(Space)
          group.admins.include?(user) or
            (!jr.introducer.nil? && jr.introducer == user)
        else
          false
        end
      end

      # Posts
      # TODO: maybe space admins should be able to alter posts
      can :read, Post, :space => { :public => true }
      can [:read, :create, :reply_post], Post do |post|
        post.space.users.include?(user)
      end
      can [:read, :reply_post, :edit, :update, :destroy], Post, :author_id => user.id

      # News
      # Only admins can create/alter news, the rest can only read
      # note: :show because :index is only for space admins
      can :show, News, :space => { :public => true }
      can :show, News do |news|
        news.space.users.include?(user)
      end
      can :manage, News do |news|
        news.space.admins.include?(user)
      end

      # Events
      # TODO: maybe space admins should be able to alter events they did not create but that
      #   are in their spaces
      can :read, Event, :space => { :public => true }
      can [:read, :create], Event do |event|
        event.space.users.include?(user)
      end
      can [:read, :edit, :update, :destroy], Event, :author_id => user.id

      # Attachments
      # TODO: there are some :create_attachment's still in the code, remove them
      # TODO: maybe space admins should be able to alter attachments
      can :manage, Attachment do |attach|
        attach.space.admins.include?(user) && attach.space.repository?
      end

      can [:read, :create], Attachment do |attach|
        attach.space.users.include?(user) && attach.space.repository?
      end

      can :read, Attachment, :space => { :public => true, :repository => true }

      can [:read, :destroy], Attachment, :author_id => user.id, :space => { :repository => true }

      # can :manage, Attachment do |attach|
      #   if attach.parent.present?
      #     can? :manage, attach.parent
      #   end
      # end

      # Permissions
      # Only space admins can update user roles/permissions
      can [:read, :edit, :update], Permission do |perm|
        case perm.subject_type
        when "Space"
          admins = perm.subject.admins
        when "Event"
          admins = perm.subject.space.admins
        else
          admins = []
        end
        admins.include?(user)
      end
    end

    private

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
      can [:end, :join_options, :create_meeting, :fetch_recordings], BigbluebuttonRoom do |room|
        user_is_owner_or_belongs_to_rooms_space(user, room)
      end

      # Users can recording meetings in their rooms, but only if they have the record flag set.
      # `:record_meeting` is a custom name, not an action that exists in the controller
      can :record_meeting, BigbluebuttonRoom do |room|
        user.can_record && user_is_owner_or_belongs_to_rooms_space(user, room)
      end

      # Currently only user rooms can be updated
      can [:update], BigbluebuttonRoom do |room|
        room.owner_type == "User" && room.owner.id == user.id
      end

      # some actions in rooms should be accessible to any logged user
      # some of them will do the authorization themselves (e.g. permissions for :join
      # will change depending on the user and the target room)
      can [:invite, :invite_userid, :auth, :running,
           :join, :external, :external_auth, :join_mobile], BigbluebuttonRoom

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
      response = false
      unless recording.room.nil?
        if recording.room.owner_type == "Space"
          space = Space.find(recording.room.owner_id)
          response = space.public
        end
      end
      response
    end

  end

  class AnonymousAbility < BaseAbility

    def register_abilities(user=nil)
      abilities_for_bigbluebutton_rails(user)

      can :read, Profile do |profile|
        case profile.visibility
        when Profile::VISIBILITY.index(:everybody)
          true
        else
          false
        end
      end
      can [:read, :current], User, :disabled => false
      can [:read, :webconference, :recordings], Space, :public => true
      can :select, Space
      can :read, Post, :space => { :public => true }
      can :show, News, :space => { :public => true }
      can :read, Event, :space => { :public => true }
      can :read, Attachment, :space => { :public => true, :repository => true }
    end

    private

    def abilities_for_bigbluebutton_rails(user)
      # Recordings of public spaces are available to everyone
      can [:space_show, :play], BigbluebuttonRecording do |recording|
        response = false
        unless recording.room.nil?
          if recording.room.owner_type == "Space"
            space = Space.find(recording.room.owner_id)
            response = space.public
          end
        end
        response
      end

      # some actions in rooms should be accessible to anyone
      can [:invite, :invite_userid, :auth, :running], BigbluebuttonRoom do |room|
        # filters invalid rooms only
        room.owner_type == "User" || room.owner_type == "Space"
      end
    end

  end

end
