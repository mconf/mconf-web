# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Site < ActiveRecord::Base

  serialize :visible_locales, Array

  before_validation :validate_and_adjust_max_upload_size

  # Returns the current (default) site
  def self.current
    first || create
  end

  def signature_in_html
    if signature.blank?
      name
    else
      signature.gsub(/\r\n?/, '<br>')
    end
  end

  # HTTP protocol based on SSL setting
  def protocol
    "http#{ ssl? ? 's' : nil }"
  end

  # Domain http url considering protocol
  # e.g. http://server.org
  def domain_with_protocol
    "#{protocol}://#{domain}"
  end

  # Nice formatted email address for the Site
  def email_with_name
    "#{name} <#{email}>"
  end

  def formatted_max_upload_size
    Mconf::Filesize.human_file_size(self.max_upload_size)
  end

  private

  def validate_and_adjust_max_upload_size
    if max_upload_size_changed?
      if self.max_upload_size.blank?
        write_attribute(:max_upload_size, nil)
      else
        value = Mconf::Filesize.convert(self.max_upload_size)
        if value.nil?
          self.errors.add(:max_upload_size, :invalid)
        else
          write_attribute(:max_upload_size, value.to_s)
        end
      end
    end
  end
end
