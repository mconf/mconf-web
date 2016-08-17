module Mconf
  module ApprovalModule

    def self.included base
      base.before_create :automatically_approve, unless: :require_approval?
    end

    def automatically_approve
      self.approved = true
    end

    # Starts the process of sending a notification to the model that was approved.
    def create_approval_notification(approved_by)
      create_activity 'approved', owner: approved_by, recipient: approved_by
    end

    def approve!
      update_attributes(approved: true)
    end

    # Sets the user as not approved
    def disapprove!
      update_attributes(approved: false)
    end

    # Should be overrided in the model to denote whether it needs to be approved
    def needs_approval?
      false
    end
  end
end
