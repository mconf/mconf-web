# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Validates the value of an attribute against the identifiers in the application:
#  * Space#slug
#  * User#slug
# Invalidates the record if the value is already taken.
# Uses case-insensitive comparisons.
class IdentifierUniquenessValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank?
      spaces = Space.with_disabled.where("lower(slug) = ?", value.downcase)
      if record.is_a?(Space) && !record.new_record?
        spaces = spaces.where.not(id: record.id)
      end

      users = User.with_disabled.where("lower(slug) = ?", value.downcase)
      if record.is_a?(User) && !record.new_record?
        users = users.where.not(id: record.id)
      end

      if spaces.count > 0 || users.count > 0
        record.errors[attribute] << (options[:message] || I18n.t('errors.messages.taken'))
      end
    end
  end
end
