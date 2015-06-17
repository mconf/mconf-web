# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class BaseWorker
  # Make everyone who inherits from BaseWorker an exclusive lock worker
  # In the future if we change libs or need to add more stuff, change only here
  extend Resque::Plugins::LockTimeout

end
