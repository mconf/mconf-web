module Mconf
  module DisableModule

    # Disable the resource from the website.
    # This can be used by global admins as a mean to disable access and indexing of this resource in all areas of
    # the site. This acts as if it has been deleted, but the data is still there in the database and it can be
    # enabled back with the method 'enable'
    def disable
      before_disable
      update_attributes(disabled: true)
    end

    # Re-enables a previously disabled resource
    def enable
      before_enable
      self.update_attributes(disabled: false)
    end

    def enabled?
      !disabled?
    end

    def before_disable
      # can be implemented by a class which includes this module
    end

    def before_enable
      # can be implemented by a class which includes this module
    end
  end
end
