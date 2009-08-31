# Modifications of Station Engine

# In Global authorization, users that are superusers are gods
# This module allows implementing this feature in all classes that implement authorizes?
module ActiveRecord::Authorization::InstanceMethods
  alias authorize_without_superuser authorize?

  def authorize_with_superuser(permission, options = {})
    return true if options[:to] && options[:to].superuser

    authorize_without_superuser(permission, options)
  end

  alias authorize? authorize_with_superuser
end
