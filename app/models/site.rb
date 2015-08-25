# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Site < ActiveRecord::Base

  serialize :visible_locales, Array
  serialize :allowed_to_record, Array

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

  def allowed_to_record_string
    if allowed_to_record.blank?
      ""
    else
      allowed_to_record.join("\n")
    end
  end

  def allowed_to_record=(r)
    if r.kind_of?(String)
      write_attribute(:allowed_to_record, r.split(/[,;\n\r]+/))
    else
      write_attribute(:allowed_to_record, r)
    end
  end

end
