# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

# TODO: permissions
#       review

class PermissionsController < ApplicationController
  load_and_authorize_resource
  before_filter :subject

  def update
    @permission[:role_id] = params[:join_request][:role_id]

    if @permission.update_attributes(params[:permission])
      respond_to do |format|
        format.html {
          flash[:success] = t('permission.update.success')
          redirect_to request.referer
        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = @update_errors
          redirect_to request.referer
        }
      end
    end
  end

  def destroy
    @permission.destroy

    respond_to do |format|
      format.html {
        redirect_to request.referer
      }
    end
  end

  private

  def subject
    @subject ||= @permission.subject
  end

end
