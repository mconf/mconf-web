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

class HomesController < ApplicationController
  
  before_filter :authentication_required

  
  def index
  end

  
  def show
    unless current_user.spaces.empty?
      @today_events = Event.in(current_user.spaces).all(:conditions => ["start_date > :now_date AND start_date < :tomorrow", 
        {:now_date=> Time.now, :tomorrow => Date.tomorrow}], :order => "start_date DESC")
      @tomorrow_events = Event.in(current_user.spaces).all(:conditions => ["start_date > :tomorrow AND start_date < :day_after_tomorrow", 
        {:day_after_tomorrow=> Date.tomorrow + 1.day, :tomorrow => Date.tomorrow}], :order => "start_date DESC")
      @week_events = Event.all(:conditions => ["start_date > :day_after_tomorrow AND start_date < :one_week_more", 
        {:day_after_tomorrow=> Date.tomorrow + 1.day, :one_week_more => Date.tomorrow+7.days}], :order => "start_date DESC", :limit => 2)
      @upcoming_events = Event.in(current_user.spaces).all(:conditions => ["start_date > :one_week_more AND start_date < :one_month_more", 
        {:one_week_more => Date.tomorrow+7.days, :one_month_more => Date.tomorrow+37.days}], :order => "start_date DESC", :limit => 2)
      if @upcoming_events.size<2
        @upcoming_events = Event.in(current_user.spaces).all(:conditions => ["start_date > :one_month_more AND start_date < :two_months_more", 
          {:one_month_more => Date.tomorrow+37.days, :two_months_more => Date.tomorrow+67.days}], :order => "start_date DESC", :limit => 2)
      end
    else
      @today_events = []
      @tomorrow_events = []
      @week_events = []
      @upcoming_events = []
    end
    @all_contents=ActiveRecord::Content.paginate({ :page=>params[:page], :per_page=>15 },{ :containers => current_user.spaces } )
    
    #let's get the inbox for the user
    @private_messages = PrivateMessage.find(:all, :conditions => {:deleted_by_receiver => false, :receiver_id => current_user.id},:order => "created_at DESC", :limit => 3)
  
  end
end
