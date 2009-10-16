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

