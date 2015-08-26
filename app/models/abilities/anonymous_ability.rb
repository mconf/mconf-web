# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Abilities

  class AnonymousAbility < BaseAbility

    def register_abilities(user=nil)
      abilities_for_bigbluebutton_rails(user)

      # Note: For the private profile only, the public profile is always visible.
      #   Check for public profile with `can?(:show, user)` instead of `can?(:show, user.profile)`.
      can :index, Profile
      can :show, Profile do |profile|
        case profile.visibility
        when Profile::VISIBILITY.index(:everybody)
          true
        else
          false
        end
      end

      can [:index], User # restricted through Space and/or manage
      can [:show, :current], User, disabled: false

      can [:index, :select], Space
      can [:show, :webconference, :recordings], Space, public: true

      can :index, News # restricted through Space
      can :show, News, space: { public: true }

      can :index, Post # restricted through Space
      can :show, Post, space: { public: true }

      can :index, Attachment # restricted through Space
      can :show, Attachment, space: { public: true, repository: true }

      # for MwebEvents
      if Mconf::Modules.mod_loaded?('events')
        can [:show, :index, :select], MwebEvents::Event
        # Pertraining public and private event registration
        can :register, MwebEvents::Event, public: true
        can [:create, :new], MwebEvents::Participant
      end

      restrict_access_to_disabled_resources(user)
      restrict_access_to_unapproved_resources(user)
    end

    private

    def abilities_for_bigbluebutton_rails(user)
      # Recordings of public spaces are available to everyone
      can [:space_show, :play], BigbluebuttonRecording do |recording|
        recording.room.try(:public?)
      end

      # some actions in rooms should be accessible to anyone
      can [:invite, :invite_userid, :join, :join_mobile, :running], BigbluebuttonRoom do |room|
        # filters invalid rooms only
        room.owner_type == "User" || room.owner_type == "Space"
      end
    end

  end
end
