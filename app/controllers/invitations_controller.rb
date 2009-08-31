# Require Station Controller
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/controllers/invitations_controller"

class InvitationsController
  def destroy
    invitation.destroy

    respond_to do |format|
      format.html { redirect_to [ invitation.group, Admission.new ] }
      format.xml  { head :ok }
    end
  end
end

