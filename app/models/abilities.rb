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
      # Users
      # Disabled users are only visible to superusers
      can [:read, :fellows, :current, :select_users], User, :disabled => false
      can [:update], User, :id => user.id, :disabled => false

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
        message.sender_id == user.id or message.receiver_id == user.id
      end
      can :destroy, PrivateMessage do |message|
        message.sender_id == user.id or message.receiver_id == user.id
      end

      # Spaces
      can :create, Space
      can :read, Space, :public => true
      can [:read, :leave], Space do |space|
        space.users.include?(user)
      end
      can :update, Space do |space|
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
      # TODO: there are some :create_event's still in the code, remove them
      # TODO: maybe space admins should be able to alter events
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
      # # AgendaEntry
      # authorization_delegate(:event,:as => :content)
      # authorization_delegate(:space,:as => :content)
      # # Agenda
      # authorization_delegate(:space,:as => :content)
      # # Permission
      # authorization_delegate(:stage)
      # # AgendaDivider
      # authorization_delegate(:event,:as => :content)
      # authorization_delegate(:space,:as => :content)
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
      can :read, Space, :public => true
      can :read, Post, :space => { :public => true }
      can :read, News, :space => { :public => true }
      can :read, Event, :space => { :public => true }
      can :read, Attachment, :space => { :public => true, :repository => true }
    end
  end

end
