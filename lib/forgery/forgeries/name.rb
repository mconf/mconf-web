# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Forgery::Name < Forgery

  def self.unique_full_name(n)
    "#{self.full_name} #{n}"
  end

  # Unique names for events
  def self.unique_event_name(n)
    "#{self.company_name} #{n}"
  end

  # Unique names for spaces
  def self.unique_space_name(n)
    unique_event_name(n)
  end
end
