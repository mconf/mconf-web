# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

class FrontpageController < ApplicationController

  layout 'clean'

  def show
   respond_to do |format|
      if user_signed_in?
        format.html { redirect_to my_home_path }
      else
        format.html
      end
    end
  end

end
