# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

# Require Station Model
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/models/performance"

class Performance
  after_create { |perfor|
    user = perfor.agent
    if perfor.stage.is_a?(Space) && user.is_a?(User)
      space = perfor.stage
      role = perfor.role
      group = Group.find_by_name(space.emailize_name)
      if group
        if (role == Role.find_by_name("Admin") || role == Role.find_by_name("User")) && !group.users.include?(user)
          user_ids = []
          group.users.each do |u|
            user_ids << "#{u.id}"
          end
          user_ids << "#{user.id}"
      
          group.update_attributes(:user_ids => user_ids)
        end
      end
    end
  }

  # Destroy Space group memberships before leaving the Space
  before_destroy { |p|
    if p.stage.is_a?(Space) && p.agent.is_a?(User)
      p.agent.memberships.select{ |m| m.group && m.group.space == p.stage }.map(&:destroy)
    end
  }

  # Destroy Space admission after leaving the Space
  after_destroy { |p|
    if p.stage.is_a?(Space) && p.agent.is_a?(User)
      p.stage.admissions.find_by_candidate_id_and_candidate_type(p.agent.id, p.agent.class.base_class.to_s).try(:destroy)
    end
  }
  
end
