# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Abilities

  class SuperUserAbility < BaseAbility
    # TODO: restrict a bit what superusers can do
    def register_abilities(user)
      can :manage, :all

      cannot [:leave], Space do |space|
        !space.users.include?(user) || space.is_last_admin?(user)
      end

      # A Superuser can't remove the last admin of a space neither change its role
      cannot [:destroy, :update], Permission do |perm|
        if perm.subject_type == "Space"
          if perm.subject.present?
            perm.subject.is_last_admin?(perm.user)
          else
            false # allowed to
          end
        else
          false # allowed to
        end
      end
    end
  end
end
