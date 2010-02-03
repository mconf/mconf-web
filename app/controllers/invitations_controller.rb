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

  def index
    redirect_to [ space, Admission.new ]
  end

  def create
    @invitations = params[:invitation][:email].split(',').map(&:strip).map { |email|
      if space.actors.map{|a| a.email} && space.actors.map{|a| a.email}.include?(email)
        #the user is already in the space
        flash[:notice] = email + " " + t('invitation.not_created')
        next
      end

      if space.invitations.map{|a| a.email} && space.invitations.map{|a| a.email}.include?(email)
        #the user is already invited to the space
        flash[:notice] = email + " " + t('invitation.not_created_2')
        next
      end
      
      i = space.invitations.build params[:invitation].update(:email => email)
      i.introducer = current_user
      i
    }.compact.each(&:save)

    respond_to do |format|
      format.html { 
        redirect_to [ group, Admission.new ]
      }
    end
  end

  private

  def space
    group
  end
end

