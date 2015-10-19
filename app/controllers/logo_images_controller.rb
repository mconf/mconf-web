# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class LogoImagesController < ApplicationController
  def crop
    if params[:model_type] == 'user'
      @user = User.find_by_username(params[:model_id])
      @model = @user.profile
      @url = user_profile_path(@user)
      @page = t('avatar.crop')
      @aspect_ratio = 1
      @width = 100
    elsif params[:model_type] == 'space'
      @space = Space.find_by_permalink(params[:model_id])
      @model = @space
      @url = space_path(@space)
      @page = t('logo.crop')
      @aspect_ratio = 4/3.0
      @width = 131
    end
    render :layout => false
  end
end
