# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Abilities

  class BaseAbility
    include CanCan::Ability

    def initialize(user=nil)
      # remove the default aliases so we use explicit actions
      clear_aliased_actions

      register_abilities(user)
    end

    # Note: when restricting permissions defined using blocks, we cannot use `:manage`,
    # otherwise it will always block actions over collections, since these don't
    # evaluate the block. (e.g. MwebEvents::Event#index would be always blocked
    # for everyone)

    # Remove access for anything related to disabled spaces and users.
    def restrict_access_to_disabled_resources(user)
      cannot :manage, Space, disabled: true
      cannot :manage, Profile, user: { disabled: true }
      cannot :manage, Post, space: { disabled: true }
      cannot :manage, Attachment, space: { disabled: true }
      cannot :manage, News, space: { disabled: true }

      # won't use :manage so it doesn't block actions such as #index
      cannot [:show, :destroy, :edit, :update, :disable,
              :enable, :approve, :disapprove, :confirm, :show,
              :fellows, :current, :select, :update_password], User, disabled: true

      cannot [:update_full_name], Profile do |profile|
        profile.user.disabled?
      end

      # only actions over members, not actions over the collection
      actions = [:show, :accept, :decline]
      cannot actions, JoinRequest do |jr|
        jr.group_type == "Space" && jr.group.disabled
      end

      if Mconf::Modules.mod_loaded?('events')
        # only actions over members, not actions over the collection
        actions = [:show, :edit, :update, :destroy,
                   :invite, :send_invitation, :create_participant]
        cannot actions, MwebEvents::Event do |event|
          event.owner.nil? ||
            (event.owner_type == "User" && event.owner.disabled) ||
            (event.owner_type == "Space" && event.owner.disabled)
        end

        # only actions over members, not actions over the collection
        actions = [:show, :edit, :update, :destroy] # TODO
        cannot actions, MwebEvents::Participant do |part|
          part.owner.nil? ||
            (part.owner_type == "User" && part.owner.disabled) ||
            (part.owner_type == "Space" && part.owner.disabled)
        end
      end

      # only actions over members, not actions over the collection
      actions = [:show, :edit, :update, :destroy, :running, :end, :record_meeting,
                 :invite, :invite_userid, :join_mobile, :join, :fetch_recordings,
                 :recordings, :join_options, :invitation, :send_invitation, :create_meeting]
      cannot actions, BigbluebuttonRoom do |room|
        room.owner.nil? ||
          (room.owner_type == "User" && room.owner.disabled) ||
          (room.owner_type == "Space" && room.owner.disabled)
      end
    end

    # Remove access for anything related to unapproved resources (users and spaces currently).
    def restrict_access_to_unapproved_resources(user)
      cannot [:show, :webconference, :recordings, :leave], Space do |space|
        # space admins can do it even if not approved yet
        !space.approved? && (user.nil? || !space.admins.include?(user))
      end

      cannot [:show, :create, :new, :reply_post, :destroy, :edit, :update], Post do |post|
        # space admins can do it even if not approved yet
        !post.space.approved? && (user.nil? || !post.space.admins.include?(user))
      end

      cannot [:show], News do |news|
        # space admins can do it even if not approved yet
        !news.space.approved? && (user.nil? || !news.space.admins.include?(user))
      end

      cannot [:show, :create, :new], Attachment do |attach|
        # space admins can do it even if not approved yet
        !attach.space.approved? && (user.nil? || !attach.space.admins.include?(user))
      end

      # TODO: events in a space that's not approved yet

      # only actions over members, not actions over the collection
      actions = [:show, :edit, :update, :destroy, :running, :end, :record_meeting,
                 :invite, :invite_userid, :join_mobile, :join, :fetch_recordings,
                 :recordings, :join_options, :invitation, :send_invitation, :create_meeting]
      cannot actions, BigbluebuttonRoom do |room|
        room.owner && !room.owner.approved
      end

      cannot [:update, :space_edit, :play, :space_show], BigbluebuttonRecording do |recording|
        recording.room && recording.room.owner && !recording.room.owner.approved
      end
    end
  end

end
