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
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/controllers/performances_controller"

class PerformancesController
  before_filter :performance, :only => [ :destroy, :update ]

  authorization_filter :create, :performance, :only => [ :new, :create ]
  authorization_filter :read,   :performance, :only => [ :index, :show ]
  authorization_filter :update, :performance, :only => [ :edit, :update ]
  authorization_filter :delete, :performance, :only => [ :destroy ]

  
  def destroy
    @performance.destroy

    respond_to do |format|
      format.html { 
        redirect_to(@performance.stage.authorize?(:read, :to => current_agent) ? request.referer : root_path)
      }

      format.js {
        index_data
      }
    end
  end
  
  def create
    @performance = Performance.new(params[:performance])
    @performance.stage = stage

    if @performance.save
      respond_to do |format|
        format.html{
          flash[:success] = t('role.added', :role => @performance.role.name, :agent => @performance.agent.name)
          redirect_to request.referer
        }
        format.js {
          index_data
        }
      end
    else
      respond_to do |format|
        format.html{
          flash[:error] = @performance.errors.to_xml
          redirect_to request.referer
        }
        format.js
      end
    end
  end
  
  def update 
    @update_errors=""
    if params[:update_groups]
      user=User.find(@performance.agent_id)
      space=Space.find(@performance.stage_id)
      
      #Groups to delete
      if params[:groups_to_delete]
        groups_to_delete = space.groups.select{|g| g.users.include?(user) && !params[:groups_to_delete].map{|a| a.to_i}.include?(g.id)} 
      else
        groups_to_delete = space.groups.select{|g| g.users.include?(user)}
      end
      for group in groups_to_delete do
        group.user_ids -= [user.id] 
        unless group.save
          @update_errors += group.errors + "</br>"
        end
      end
      
      #New groups added
      if params[:groups_to_add] && params[:groups_to_add][:id] != ""
        group = Group.find(params[:groups_to_add][:id])
        group.user_ids += [user.id] 
        unless group.save
          @update_errors += group.errors + "</br>"
        end
      end
    end   
    # Prevent Performance forge
    params[:performance].delete(:stage_id)
    params[:performance].delete(:stage_type)

    unless @performance.update_attributes(params[:performance])
        @update_errors += @performance.errors.to_xml + "</br>"
    end
    
    if @update_errors==""
      respond_to do |format|
        format.html {
          flash[:success] = t('performance.updated')
          redirect_to request.referer
        }
        format.js {

        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = @update_errors
          redirect_to request.referer
        }
        format.js{
        } 
      end
    end
  end
end
