# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

options = {
  :preserve_styles => true,
  :remove_ids => true,
  :remove_comments => true
  #:generate_text_part => false,
}
Premailer::Rails.config.merge!(options)
