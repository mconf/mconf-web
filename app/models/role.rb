# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Role < ActiveRecord::Base
  # TODO: permissions
  # has_many :invitations

  has_many :permissions
  validates :name, :presence => true, :uniqueness => true
end
