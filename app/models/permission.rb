# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Permission < ActiveRecord::Base
  belongs_to :role
  belongs_to :user
  belongs_to :subject, :polymorphic => true

  validates :user, :presence => true
  validates :subject, :presence => true
  # note: has to be role_id, not the association name (role)
  validates :role, :presence => true # to prevent invalid role_id
  validates :role_id, :presence => true

  validates :user_id, :uniqueness => {:scope => [:subject_id, :subject_type]}
end
