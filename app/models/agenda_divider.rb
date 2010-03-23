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

class AgendaDivider < ActiveRecord::Base
  belongs_to :agenda
  
  default_scope :order => 'start_time ASC'
  
  after_save do |divider|
    divider.event.syncronize_date
  end
  
  def end_time
    start_time
  end
  
  def event
    agenda.event
  end
  
   #returns the day of the agenda entry, 1 for the first day, 2 for the second day, ...
  def event_day
    return ((start_time - event.start_date + event.start_date.hour.hours)/86400).floor + 1
  end
end