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

class Profile < ActiveRecord::Base
  belongs_to :user
  accepts_nested_attributes_for :user

  acts_as_taggable :container => false
  has_logo :class_name => "Avatar"
  
  # The order implies inclusion: everybody > members > public_fellows > private_fellows
  VISIBILITY = [:everybody, :members, :public_fellows, :private_fellows, :nobody]
  
  before_validation do |profile|
    if profile.url
      if (profile.url.index('http') != 0)
        profile.url = "http://" << profile.url 
      end
    end
  end
  
  
  authorizing do |agent, permission|
    if self.user == agent
      true
    elsif (permission == :read)
      case visibility
        when VISIBILITY.index(:everybody)
          true
        when VISIBILITY.index(:members)
          agent != Anonymous.current
        when VISIBILITY.index(:public_fellows)
          self.user.public_fellows.include?(agent)
        when VISIBILITY.index(:private_fellows)
          self.user.private_fellows.include?(agent)
        when VISIBILITY.index(:nobody)
          false
      end
    end
  end
end
