# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# TODO: permissions
#       review

class PermissionsController < ApplicationController
  load_and_authorize_resource

  def update
    if @permission.update_attributes(permission_params)
      flash[:success] = t('permission.update.success')
    else
      flash[:error] = t('permission.update.failure')
    end
    redirect_to request.referer
  end

  def destroy
    @permission.destroy
    redirect_to request.referer
  end

  allow_params_for :permission
  def allowed_params
    [ :role_id ]
  end
end
