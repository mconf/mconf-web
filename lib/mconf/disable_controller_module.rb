module Mconf
  module DisableControllerModule
    def enable
      resource = instance_variable_get("@#{controller_name.singularize}")

      unless resource.disabled?
        flash[:error] = t("flash.#{controller_name}.enable.failure", :name => resource.name)
      else
        resource.enable
        resource.reload
        unless resource.disabled?
          flash[:notice] = enable_notice
        else
          flash[:error] = enable_unable_fail
        end
      end

      puts flash
      respond_to do |format|
        format.html { redirect_to enable_back_path }
      end
    end

    def disable
      resource = instance_variable_get("@#{controller_name.singularize}")

      resource.disable
      flash[:notice] = disable_notice
      respond_to do |format|
        format.html { redirect_to disable_back_path }
      end
    end

    def disable_notice
      t("flash.#{controller_name}.disable.notice")
    end

    def enable_notice
      t("flash.#{controller_name}.enable.notice")
    end

    def enable_unable_fail
      t("flash.#{controller_name}.enable.unable", name: resource.name)
    end

    def enable_back_path
      :back
    end

    def disable_back_path
      :back
    end
  end
end