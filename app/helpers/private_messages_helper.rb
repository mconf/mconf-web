# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

module PrivateMessagesHelper
  def getCospaceUsers ()
    # Fixme, optimize this method
    if @space
      @space.actors - Array(current_user)
    else
      current_user.fellows - Array(current_user)
    end
    
  end
end
