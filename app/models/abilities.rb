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

  class SuperUserAbility
    include CanCan::Ability

    # TODO: restrict a bit what superusers can do
    def initialize(user)
      can :manage, :all
    end
  end

  class MemberAbility
    include CanCan::Ability

    def initialize(user)
      # Webconf rooms
      # Not many things are done here, several authorization steps are done by the gem
      # BigbluebuttonRails inside each action

      # Can do the actions below if he's the owner or if he belongs to the space (with any role)
      # that owns the room.
      # `:create_meeting` is a custom name, not an action that exists in the controller
      can [:end, :join_options, :create_meeting, :fetch_recordings], BigbluebuttonRoom do |room|
        if (room.owner_type == "User" && room.owner.id == user.id)
          true
        elsif (room.owner_type == "Space")
          space = Space.find(room.owner.id)
          space.users.include?(user)
        else
          false
        end
      end

      # some actions in rooms should be accessible to any logged user
      # some of them will do the authorization themselves (e.g. permissions for :join
      # will change depending on the user and the target room)
      can [:invite, :invite_userid, :auth, :running,
           :join, :external, :external_auth, :join_mobile], BigbluebuttonRoom

      # a user can do these actions below in recordings of his own room or recordings of
      # rooms of either public spaces or spaces he's a member of
      can [:show, :play], BigbluebuttonRecording do |recording|
        response = false
        unless recording.room.nil?
          if recording.room.owner_type == "User" && recording.room.owner_id == user.id
            response = true
          elsif recording.room.owner_type == "Space"
            space = Space.find(recording.room.owner_id)
            if space.public
              response = true
            else
              response = space.users.include?(user)
            end
          end
        end
        response
      end

      # Users
      # Disabled users are only visible to superusers
      can [:read, :fellows, :current, :select], User, :disabled => false
      can [:update, :destroy], User, :id => user.id, :disabled => false

      # User profiles
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
      can [:read, :update], Profile, :user_id => user.id

      # Private messages
      can :create, PrivateMessage
      can :read, PrivateMessage do |message|
        [message.sender_id, message.receiver_id].include?(user.id)
      end
      can :destroy, PrivateMessage do |message|
        [message.sender_id, message.receiver_id].include?(user.id)
      end

      # Spaces
      can :create, Space
      can [:read, :webconference, :recordings], Space, :public => true
      can :join_request_new, Space
      can :join_request_create, Space
      can [:read, :webconference, :recordings, :leave], Space do |space|
        space.users.include?(user)
      end

      # Only the admin can destroy or update information on a space
      can [:destroy, :update, :join_request_update, :join_request_index, :user_permissions], Space do |space|
        space.admins.include?(user)
      end

      # Posts
      # TODO: maybe space admins should be able to alter posts
      can :read, Post, :space => { :public => true }
      can [:read, :create, :reply_post], Post do |post|
        post.space.users.include?(user)
      end
      can [:read, :reply_post, :update, :destroy], Post, :author_id => user.id

      # News
      # Only admins can create/alter news, the rest can only read
      can :read, News, :space => { :public => true }
      can :read, News do |news|
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
      can [:read, :update, :destroy], Event, :author_id => user.id

      # Attachments
      # TODO: there are some :create_attachment's still in the code, remove them
      # TODO: maybe space admins should be able to alter attachments
      can :read, Attachment, :space => { :public => true }
      can [:read, :create], Attachment do |attach|
        attach.space.users.include?(user)
      end
      can [:read, :destroy], Attachment, :author_id => user.id
      # can't do anything if attachments are disabled in the space
      cannot :manage, Attachment do |attach|
        !attach.space.repository?
      end
      # can :manage, Attachment do |attach|
      #   if attach.parent.present?
      #     can? :manage, attach.parent
      #   end
      # end

      # Permissions
      # Only space admins can update user roles/permissions
      can [:read, :update], Permission do |perm|
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

      # TODO: station's Stage
      # authorizing do |agent, permission|
      #   p = stage_permissions.find_by_user_id(agent.id, :include => { :role => :permissions })
      #   return nil unless p.present?
      #   p.role.permissions.map(&:to_array).include?(Array(permission)) || nil
      # end

      # TODO
      # # Permission
      # authorization_delegate(:stage)
    end
  end

  class AnonymousAbility
    include CanCan::Ability

    def initialize
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
      can :read, Post, :space => { :public => true }
      can :read, News, :space => { :public => true }
      can :read, Event, :space => { :public => true }
      can :read, Attachment, :space => { :public => true, :repository => true }

      # Recordings of public spaces are available to everyone
      can [:show, :play], BigbluebuttonRecording do |recording|
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
