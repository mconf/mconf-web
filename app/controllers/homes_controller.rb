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

require 'bigbluebutton-api'

class HomesController < ApplicationController
  
  before_filter :authentication_required

  def index
  end
  
  def show

    #TODO temporary implementation of a bbb room for this home
    @bbb_info = {}
    @bbb_info[:infos] = BBB_API.get_meetings()


    unless current_user.spaces.empty?
      @events_of_user = Event.in(current_user.spaces).all(:order => "start_date ASC")
    end
    @contents_per_page = params[:per_page] || 15
    @contents = params[:contents].present? ? params[:contents].split(",").map(&:to_sym) : Space.contents 
    @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>@contents_per_page.to_i, :order=>'updated_at DESC' },{ :containers => current_user.spaces, :contents => @contents} )

    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)
  end

end
