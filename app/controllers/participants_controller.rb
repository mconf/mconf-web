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

class ParticipantsController < ApplicationController
  
  
  def create

    @participant = Participant.new(params[:participant])
    @participant.event_id = Event.find_by_permalink(params[:event_id]).id
    @participant.user = current_user
    @participant.email = current_user.email
    if @participant.save    
      respond_to do |format|
      format.html {
      flash[:success] = t('participant.created')
        redirect_to request.referer
      }
      format.js
    end
  else
      flash[:error] = t('participant.error.create')
      redirect_to request.referer    
  end
end
  
  def update
    @participant = Participant.find(params[:id])
    if @participant.update_attributes(params[:participant])
      respond_to do |format|
      format.html {
      flash[:success] = t('participant.created')
      redirect_to request.referer
      }

      end
    else
      flash[:error] = t('participant.error.create')
      redirect_to request.referer
    end
  end
  
end