module Mconf
  module ApprovalControllerModule

    def approve
      # resources that are not approved can always be approved
      if require_approval? || !resource.approved?
        resource = instance_variable_get("@#{controller_name.singularize}")

        resource.approve!
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
