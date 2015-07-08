# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

MwebEvents::Event.class_eval do
  include PublicActivity::Common

  def self.host
    Site.current.domain || 'example.com'
  end

  def new_activity key, user
    create_activity key, :owner => owner, :parameters => { :user_id => user.try(:id), :username => user.try(:name) }
  end

  # Temporary while we have no private events
  def public
    if owner_type == 'User'
      true # User owned spaces are always public
    elsif owner_type == 'Space'
      owner && owner.public?
    end
  end
end
