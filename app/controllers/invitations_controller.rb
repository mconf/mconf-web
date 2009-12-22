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

# Require Station Controller
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/controllers/invitations_controller"

class InvitationsController
  skip_before_filter :candidate_authenticated, :only => [ :show, :update ]
  
  
  # GET /invitations/1
  # GET /invitations/1.xml
  def show
    get_show_params
    respond_to do |format|
      format.html {
          @candidate = User.new
          render :action => "show"
      }
      format.xml  { render :xml => @invitation }
    end
  end

  def get_show_params
    unless @invitation
      flash[:error] = t('invitation.not_found')
      redirect_to root_path
      return
    end
  end
  
  
  
  def destroy
    invitation.destroy

    respond_to do |format|
      format.html { redirect_to [ invitation.group, Admission.new ] }
      format.xml  { head :ok }
    end
  end
end

