module Abilities

  class BaseAbility
    include CanCan::Ability

    def initialize(user=nil)
      # remove the default aliases to remove the one that says:
      #   `alias_action :edit, to: :update`
      # we have some models where the user should have access to :update but not
      # to :edit, and this alias was binding them together.
      clear_aliased_actions
      alias_action :index, :show, to: :read
      alias_action :new, to: :create

      register_abilities(user)
    end

    # Remove access for anything related to disabled spaces and users.
    def restrict_access_to_disabled_resources
      cannot :manage, Space, disabled: true
      cannot :manage, Profile, user: { disabled: true }
      cannot :manage, Post, space: { disabled: true }
      cannot :manage, Attachment, space: { disabled: true }
      cannot :manage, News, space: { disabled: true }

      # won't use :manage so it doesn't block actions such as #index
      cannot [:show, :update, :edit, :destroy,
              :enable, :approve, :disapprove, :confirm], User, disabled: true

      # Note: on permissions we need to define using blocks, we can use `:manage`,
      # otherwise it will always block actions over collections, since these don't
      # evaluate the block. (e.g. MwebEvents::Event#index would be always blocked
      # for everyone)

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
      actions = [:show, :edit, :update, :destroy, :running, :end,
                 :invite, :invite_userid, :join_mobile, :join, :fetch_recordings,
                 :recordings, :join_options, :invitation, :send_invitation, :create_meeting]
      cannot actions, BigbluebuttonRoom do |room|
        room.owner.nil? ||
          (room.owner_type == "User" && room.owner.disabled) ||
          (room.owner_type == "Space" && room.owner.disabled)
      end

    end
  end

end
