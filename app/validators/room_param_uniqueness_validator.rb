# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Validates the value of an attribute against BigbluebuttonRoom's param. Used
# for models that have a room and use one of its attributes to generate the
# param of this room.
# Invalidates the record if the value is already taken.
# Uses case-insensitive comparisons.
class RoomParamUniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank?
      rooms = BigbluebuttonRoom.where("lower(param) = ?", value.downcase)
      if record.is_a?(User) || record.is_a?(Space)
        my_room = record.bigbluebutton_room
        rooms = rooms.where("id != ?", my_room.id) if my_room.present?
      end

      if rooms.count > 0
        record.errors[attribute] << (options[:message] || "has already been taken")
      end
    end
  end
end
