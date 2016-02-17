module Mconf::AllowParamsForModule

  # Code that to DRY out permitted param filtering
  # The controller declares allow_params_for :model_name and defines allowed_params
  def allow_params_for instance_name
    instance_name ||= controller_name.singularize.to_sym

    define_method("#{instance_name}_params") do
      unless params[instance_name].blank?
        params[instance_name].permit(*allowed_params)
      else
        {}
      end
    end
  end

end