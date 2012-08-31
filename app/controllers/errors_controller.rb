# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Error pages
# Only the error 404 is needed here, the others are just views that are rendered
# directly by ApplicationController
class ErrorsController < ApplicationController
  layout 'error'

  def error_404
  end
end
