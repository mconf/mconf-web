# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module Abilities

  class SuperUserAbility < BaseAbility
    # TODO: #1251 restrict a bit what superusers can do
    def register_abilities(user)
      can :manage, :all

      cannot [:leave], Space do |space|
        !space.users.include?(user) || space.is_last_admin?(user)
      end

      cannot [:update_password], User do |target_user|
        enabled = Site.current.local_auth_enabled?
        local = !target_user.no_local_auth?
        if target_user.superuser
          !local
        else
          !enabled || !local
        end
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

      # A superuser can not accept his join request for a space nor invitations for other users
      cannot [:accept], JoinRequest do |jr|
        (jr.candidate == user && jr.request_type == JoinRequest::TYPES[:request]) ||
        (jr.candidate != user && jr.request_type == JoinRequest::TYPES[:invite])
      end
    end
  end
end
