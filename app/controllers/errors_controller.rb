# Error pages
# Only the error 404 is needed here, the others are just views that are rendered
# directly by ApplicationController
class ErrorsController < ApplicationController
  layout 'error'

  def error_404
  end
end
