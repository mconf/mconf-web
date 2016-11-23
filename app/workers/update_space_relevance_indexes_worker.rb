# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class UpdateSpaceRelevanceIndexesWorker < BaseWorker

  def self.perform
    Resque.logger.info "* [space_indexes] Updating space relevance indexes."
    Space.calculate_last_activity_indexes!
    Resque.logger.info "* [space_indexes] Done."
  end

end