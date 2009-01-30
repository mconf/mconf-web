class PerformancesController < ApplicationController
  # Dejar paso solo al superuser
  authorization_filter :get_space, [ :manage, :Performance ]

  private

  def get_stage
    @stage ||= get_space
  end
end
