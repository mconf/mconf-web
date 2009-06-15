# Modifications of Station Engine

# In Global authorization, users that are superusers are gods
# This module allows implementing this feature in all classes that implement authorizes?
module ActiveRecord::Authorization::InstanceMethods
  alias authorizes_without_superuser authorizes?

  def authorizes_with_superuser(action, options = {})
    return true if options[:to] && options[:to].superuser

    authorizes_without_superuser(action, options)
  end

  alias authorizes? authorizes_with_superuser
end
