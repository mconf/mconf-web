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
    # evaluate the block. (e.g. Event#index would be always blocked for everyone)

    # Remove access for anything related to disabled spaces and users.
    def restrict_access_to_disabled_resources(user)
      cannot :manage, Space, disabled: true
      cannot :manage, Profile, user: { disabled: true }
      cannot :manage, Post, space: { disabled: true }
      cannot :manage, Attachment, space: { disabled: true }

      # won't use :manage so it doesn't block actions such as #index
      cannot [:show, :destroy, :edit, :update, :disable,
              :enable, :approve, :disapprove, :confirm, :show,
              :fellows, :current, :select, :update_password], User, disabled: true

      # only actions over members, not actions over the collection
      actions = [:show, :accept, :decline]
      cannot actions, JoinRequest do |jr|
        jr.group.disabled
      end

      restrict_access_to_disabled_resources_over_events(user)

      # only actions over members, not actions over the collection
      actions = [:show, :edit, :update, :destroy, :running, :end, :record_meeting,
                 :invite, :invite_userid, :join_mobile, :join, :fetch_recordings,
                 :recordings, :invitation, :send_invitation, :create_meeting]
      cannot actions, BigbluebuttonRoom do |room|
        room.owner.nil? || room.owner.disabled
      end
    end

    def restrict_access_to_disabled_resources_over_events(user)
      actions = [:show, :edit, :update, :destroy, :register,
                 :invite, :send_invitation, :create_participant]
      cannot actions, Event do |event|
        event.owner.try(:disabled)
      end

      # these actions are allowed if there's no owner set, but not if
      # the owner is disabled
      cannot [:create, :new], Event do |event|
        if ['User', 'Space'].include?(event.owner_type)
          klass = Object.const_get(event.owner_type)
          owner = klass.with_disabled.find_by(id: event.owner_id)
          owner && owner.disabled
        end
      end

      # only actions over members, not actions over the collection
      actions = [:show, :edit, :update, :destroy] # TODO review
      cannot actions, Participant do |part|
        part.event.present? && part.event.owner.try(:disabled)
      end
    end

    # Remove access for anything related to unapproved resources (users and spaces currently).
    def restrict_access_to_unapproved_resources(user)
      cannot [:show, :leave], Space do |space|
        # space admins can do it even if not approved yet
        !space.approved? && (user.nil? || !space.admins.include?(user))
      end

      cannot [:webconference, :recordings, :manage_join_requests,
              :invite, :user_permissions, :webconference_options,
              :edit_recording, :index_event], Space, approved: false

      cannot :manage, Post, space: { approved: false }
      cannot :manage, Attachment, space: { approved: false }

      cannot [:manage], JoinRequest do |jr|
        !jr.group.approved?
      end

      restrict_access_to_unapproved_resources_over_events(user)

      # only actions over members, not actions over the collection
      actions = [:show, :edit, :update, :destroy, :running, :end, :record_meeting,
                 :invite, :invite_userid, :join_mobile, :join, :fetch_recordings,
                 :recordings, :invitation, :send_invitation, :create_meeting]
      cannot actions, BigbluebuttonRoom do |room|
        room.owner && !room.owner.approved
      end

      cannot [:update, :space_edit, :play, :space_show], BigbluebuttonRecording do |recording|
        recording.room && recording.room.owner && !recording.room.owner.approved
      end
    end

    def restrict_access_to_unapproved_resources_over_events(user)
      actions = [:show, :invite, :register, :update, :destroy, :edit, :send_invitation]
      cannot actions, Event do |event|
        !event.owner.try(:approved?)
      end

      # these actions are allowed if there's no owner set, but not if
      # the owner is not approved
      cannot [:create, :new], Event do |event|
        if ['User', 'Space'].include?(event.owner_type)
          klass = Object.const_get(event.owner_type)
          owner = klass.with_disabled.find_by(id: event.owner_id)
          owner && !owner.approved?
        end
      end

      # only actions over members, not actions over the collection
      actions = [:show, :edit, :update, :destroy] # TODO review
      cannot actions, Participant do |part|
        part.event.present? && !part.event.owner.try(:approved?)
      end
    end
  end

end
