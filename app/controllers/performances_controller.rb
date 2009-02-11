class PerformancesController < ApplicationController
  # Overwrite filter from CMSplugin
  skip_before_filter :performance

  before_filter :get_space

  authorization_filter :space, [ :create, :Performance ], :only => [ :new, :create ]
  authorization_filter :space, [ :delete, :Performance ], :only => [ :destroy ]
  #Ñapa para que sólo pueda crear admin un admin
  before_filter :create_admin_by_admin, :only => [:create]

  def new
    session[:current_sub_tab] = "Add Users from App"
  end
    
  # Moved from UsersController#add_user_from_app
  def create
    session[:current_sub_tab] = "Add Users from App"
    if params[:users] && params[:user_role]
      flash[:error] = ""
      if Role.find_by_name(params[:user_role])
        @users_other_role = []
        @users_same_role = []
        for user_id in params[:users][:id]
          #let`s check if the performance already exist
          perfor = Performance.find_by_stage_id_and_stage_type_and_agent_id_and_agent_type(@space.id,"Space",user_id, "User", :conditions=>["role_id = ?", Role.find_by_name(params[:user_role])])
          if perfor==nil
            #if it does not exist we create it
            new_performance = @space.stage_performances.create :agent => User.find(user_id), :role => Role.find_by_name(params[:user_role])
            if !new_performance.valid?
              @users_other_role << User.find(user_id) 
            end
          else
            @users_same_role << User.find(user_id) 
          end
          
        end
      else        
        flash[:notice] = 'Role ' + params[:user_role] + ' does not exist.'
      end
      
      if !@users_other_role.empty? 
        flash[:error] << "The User(s) " + @users_other_role.map(&:login).join(", ") + " has another role in the space " + @space.name + " Please, remove it and try again <br/> "
      end
      if !@users_same_role.empty? 
        flash[:error] << "The User(s) " + @users_same_role.map(&:login).join(", ") + " already had the role " + params[:user_role] + " in the space " + @space.name 
      end
      if @users_other_role.empty? && @users_same_role.empty?
        flash[:error] = "Operation completed successfully"
      end
    end

    render :action => :new
  end

  # From UsersController#remove_user
  def destroy
    if params[:users] && params[:user_role]
      if Role.find_by_name(params[:user_role])
        for user_id in params[:users][:id]
          #let`s check if the performance exist
          perfor = @space.stage_performances.find_by_agent_id(params[:users][:id], :conditions=>["role_id = ?", Role.find_by_name(params[:user_role])])
          if perfor
            #if it exists we remove it
            @space.stage_performances.delete perfor
          end
        end
      end
    else
      perfor = @space.stage_performances.find_by_agent_id(params[:id])
      if perfor
        #if it exists we remove it
        @space.stage_performances.delete perfor
      end  
    end

    respond_to do |format|
      format.html { render :action =>'new'  }
      format.xml  { head :ok }
      format.atom { head :ok }
    end

  end


  private

  def create_admin_by_admin
    if params[:from_app] && params[:user_role] == "Admin"
       if @space.role_for?(current_user, :name => 'Admin') || current_user.superuser == true   
         return true
       else 
         not_authorized()
       end
    else
      return true
    end
  end

  def stage
    @stage ||= get_space
  end
end
