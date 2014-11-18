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

  def render404
    @exception = env["action_dispatch.exception"]
    @route = @exception.message.split('"')[1]
    respond_to do |format|
      format.html { render action: 'error_' + request.path[1..-1] }
      format.json { render json: {status: request.path[1..-1], error: @exception.message} }
    end
  end

end
