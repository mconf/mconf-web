# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class Forgery::Internet < Forgery
  def self.unique_email_address(n)
    user_name + n.to_s + '@' + domain_name
  end

  def self.unique_user_name(n)
    "#{self.user_name}-#{n}"
  end

  def self.unique_permalink(p)
    unique_user_name(p)
  end
end
