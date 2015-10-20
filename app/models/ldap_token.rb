# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class LdapToken < ActiveRecord::Base
  # attr_accessible :data, :identifier, :user_id
  belongs_to :user
  validates :identifier, presence: true, uniqueness: true

  def self.user_created_by_ldap?(u)
    LdapToken.where(user_id: u.id, new_account: true).present?
  end
end
