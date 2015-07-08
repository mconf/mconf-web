# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class News < ActiveRecord::Base
  include PublicActivity::Common

  belongs_to :space

  validates_presence_of :title, :text, :space_id

  def new_activity key, user
    create_activity key, :owner => space, recipient: user, parameters: { :username => user.name }
  end
end
