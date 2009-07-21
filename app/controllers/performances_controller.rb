# Require Station Controller
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/controllers/performances_controller"

class PerformancesController
  
  before_filter :performance, :only => [ :destroy, :update ]
  
  def destroy
    @performance.destroy

    respond_to do |format|
      format.html { 
        redirect_to(@performance.stage.authorizes?(:read, :to => current_agent) ? request.referer : root_path)
      }

      format.js {
        index_data
      }
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
        @update_errors += @performance.errors + "</br>"
    end
    
    if @update_errors==""
      respond_to do |format|
        format.html {
          flash[:success] = "User performance successfully updated."
          redirect_to request.referer
        }
        format.js {

        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = update_errors
          redirect_to request.referer
        }
        format.js{
        } 
      end
    end
  end
end
