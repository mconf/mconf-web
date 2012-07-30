# -*- coding: utf-8 -*-
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

class SingularAgent < ActiveRecord::Base
  def superuser
    false
  end
  alias superuser? superuser

  def profile
    nil
  end

  def email
    ""
  end

  def <=>(agent)
    self.name <=> agent.name
  end

  def disabled
    false
  end

  def active?
    true
  end

  def expanded_post
    false
  end

  #-#-# from station

  acts_as_agent :authentication => [],
                :invite         => false

  class << self
    def current
      @current ||= first || create
    end
  end

  def name
    I18n.t :name, :scope => "singular_agent.#{ self.class.to_s.underscore }"
  end

  alias login name
  alias username name
end
