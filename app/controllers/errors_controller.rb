# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# Error pages
# Only the error 404 is needed here, the others are just views that are rendered
# directly by ApplicationController

class ErrorsController < ApplicationController
  layout 'no_sidebar'

  def on_error
    @exception = env["action_dispatch.exception"]

    # Prevent further errors if for some reason we reach this controller with no exception.
    # We 'll just fill the variables with an 'Unknown error' and let the application render it
    if @exception.blank?
      @exception = StandardError.new 'Unknown error'
      @route = my_home_path
      status = 500
    else
      @route = @exception.message.split('"')[1]
      status = request.path[1..-1]
    end

    respond_to do |format|
      format.html { send("render_#{status}", @exception) }
      format.json { render json: { status: status, error: @exception.message } }
    end
  end

end
