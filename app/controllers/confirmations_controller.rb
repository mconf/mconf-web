# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class ConfirmationsController < Devise::ConfirmationsController
  layout 'no_sidebar'

  before_filter :check_registration_enabled, :only => [:new]

  private

  def check_registration_enabled
    unless current_site.registration_enabled?
      raise ActionController::RoutingError.new('Not Found')
    else
      true
    end
  end

end
