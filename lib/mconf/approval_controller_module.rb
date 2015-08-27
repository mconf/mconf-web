module Mconf
  module ApprovalControllerModule
    def approve
      if require_approval?
        resource = instance_variable_get("@#{controller_name.singularize}")

        resource.approve!
        resource.create_approval_notification(current_user)
        flash[:notice] = t("#{controller_name}.approve.approved", :name => resource.name)
      else
        flash[:error] = t("#{controller_name}.approve.not_enabled")
      end
      redirect_to :back
    end

    def disapprove
      if require_approval?
        resource = instance_variable_get("@#{controller_name.singularize}")

        resource.disapprove!
        flash[:notice] = t("#{controller_name}.disapprove.disapproved", :name => resource.name)
      else
        flash[:error] = t("#{controller_name}.disapprove.not_enabled")
      end
      redirect_to :back
    end

    # Override in the controller
    def require_approval?
      false
    end
  end
end