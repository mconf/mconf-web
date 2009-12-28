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

class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Notifier.deliver_confirmation_email(user) unless user.activated_at
  end

  def after_save(user)
    if user.class.password_recovery?
      Notifier.deliver_activation(user) if user.recently_activated?
      Notifier.deliver_lost_password(user) if user.recently_lost_password?
      Notifier.deliver_reset_password(user) if user.recently_reset_password?
    end
  end
end
