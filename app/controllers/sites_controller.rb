# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class SitesController < ApplicationController
  before_filter :authenticate_user!
  authorize_resource :class => false
  layout 'no_sidebar'

  def show
    @site = current_site
  end

  def edit
    @site = current_site
  end

  def update
    respond_to do |format|
      if current_site.update_attributes(params[:current_site])
        flash[:success] = t('site.updated')
        format.html { redirect_to site_path }
      else
        format.html { render :action => "edit" }
      end
    end
  end
end
