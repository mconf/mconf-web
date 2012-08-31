# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Membership < ActiveRecord::Base
  belongs_to :group
  belongs_to :user

  validates_presence_of :group_id, :user_id
end
