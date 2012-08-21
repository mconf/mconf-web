class Ability
  include CanCan::Ability

  # TODO: won't user.id checks fail if user is a new_record?
  def initialize(user)

    user ||= User.new # guest user (not logged in)

    # User profiles
    can :read, Profile do |profile|
      case profile.visibility
      when Profile::VISIBILITY.index(:everybody)
        true
      when Profile::VISIBILITY.index(:members)
        !user.new_record?
      when Profile::VISIBILITY.index(:public_fellows)
        profile.user.public_fellows.include?(user)
      when Profile::VISIBILITY.index(:private_fellows)
        profile.user.private_fellows.include?(user)
      when Profile::VISIBILITY.index(:nobody)
        false
      end
    end
    can :manage, Profile, :user_id => user.id

    # Posts
    can :read, Post, :space => { :public => true }
    can :read, Post do |post|
      post.space.users.include?(user)
    end
    can :create_post, Space do |space|
      space.users.include?(user)
    end
    # TODO: why not :manage?
    # TODO: && space.authorize?([ :create, :content ], :to => agent)
    can [:update, :destroy], Post, :author_id => user.id

    # News
    can :read, News, :space => { :public => true }
    can :read, News do |news|
      news.space.users.include?(user)
    end
    can :manage, News do |news|
      news.space.admins.include?(user)
    end

    # Events
    can :read, Event, :space => { :public => true }
    can :read, Event do |event|
      event.space.users.include?(user)
    end
    can :create_event, Space do |space|
      space.users.include?(user)
    end
    # TODO: why not :manage?
    can [:update, :destroy], Event, :author_id => user.id

    # Attachments
    can :read, Attachment, :space => { :public => true }
    can :read, Attachment do |attach|
      attach.space.users.include?(user)
    end
    can :create_attachment, Space do |space|
      space.users.include?(user)
    end
    # TODO: why not :manage?
    can :destroy, Attachment, :author_id => user.id
    # can't do anything if attachments are disabled in the space
    # false unless space.repository? || ( permission == :read && ! new_record? )
    cannot :manage, Attachment do |attach|
      !attach.space.repository?
    end
    # can :manage, Attachment do |attach|
    #   if attach.parent.present?
    #     can? :manage, attach.parent
    #   end
    # end

    # Spaces
    can :read, Space, :public => true
    can :read, Space do |space|
      space.users.include?(user)
    end
    can :create, Space unless user.new_record?
    can :manage, Space do |space|
      space.admins.include?(user)
    end

    # Users
    can :read, User
    can :manage, User, :id => user.id, :disabled => false
    cannot :manage, User, :disabled => true

    # Private messages
    can :read, PrivateMessage do |message|
      message.sender_id == user.id or message.receiver_id == user.id
    end
    can :manage, PrivateMessage, :sender_id => user.id
    cannot :edit, PrivateMessage # can't edit any private message

    # Permissions
    can :update, Permission do |perm|
      # only space admins can update user roles/permissions
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
    # can :destroy, Permission, :user_id => user.id

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

    # Superusers
    can :manage, :all if user.superuser?

  end
end
