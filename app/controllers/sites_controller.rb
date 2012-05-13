# -*- coding: utf-8 -*-
# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

class SitesController < ApplicationController
  authorization_filter :manage, :current_site

  #-#-# from station

  # GET /site
  # GET /site.xml
  def show
    @site = current_site
  end

  # GET /site/new
  # GET /site/new.xml
  def new
    redirect_to edit_site_path
  end

  # GET /site/edit
  def edit
    @site = current_site
  end

  # POST /site
  # POST /site.xml
  def create
    update
  end

  # PUT /site
  # PUT /site.xml
  def update
    respond_to do |format|
      if current_site.update_attributes(params[:current_site])
        flash[:success] = t('site.updated')
        format.html { redirect_to site_path }
        format.xml  { head :ok }
      else
        @site = current_site
        format.html { render :action => "edit" }
        format.xml  { render :xml => @site.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /site
  # DELETE /site.xml
  def destroy
    current_site.destroy if Site.count > 0

    respond_to do |format|
      format.html { redirect_to root_path  }
      format.xml  { head :ok }
    end
  end

end
