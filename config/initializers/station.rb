# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

ActiveSupport.on_load(:after_initialize) do
  if Site.table_exists?
    ActionMailer::Base.default_url_options[:host] = Site.current.domain
  end
end
