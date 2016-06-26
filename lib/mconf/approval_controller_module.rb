module Mconf
  module ApprovalControllerModule

    def self.included base
      base.after_filter :create_approval_notification, only: [:approve, :update], if: :require_approval?
    end

    def approve
      if require_approval?
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

    private

    def create_approval_notification
      resource = instance_variable_get("@#{controller_name.singularize}")

      if resource.approved? && resource.errors.empty?
        resource.create_approval_notification(current_user)
      end
    end

  end
end
