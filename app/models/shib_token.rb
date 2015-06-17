# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ShibToken < ActiveRecord::Base
  belongs_to :user
  validates :identifier, :presence => true, :uniqueness => true

  serialize :data, Hash

  def user_with_disabled
    User.with_disabled.where(id: self.user_id).first
  end
end
