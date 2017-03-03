# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Blacklists a list of reserved words. If the value used is in the list, returns an
# error in the attribute saying that the value is already in used.
class BlacklistValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value.blank?
      file = File.join(::Rails.root, "config", "reserved_words.yml")
      words = YAML.load_file(file)['words']

      if words.include?(value)
        record.errors[attribute] << (options[:message] || I18n.t('errors.messages.taken'))
      end
    end
  end
end
