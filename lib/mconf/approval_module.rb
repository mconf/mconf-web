module Mconf
  module ApprovalModule

    def self.included base
      base.before_create :automatically_approve, unless: :require_approval?
      base.before_save :new_activity_approved, if: :require_approval?
    end

    def automatically_approve
      self.approved = true
    end

    def new_activity_approved
      if self.new_record?
        # no notifications for new records
        saved_and_not_approved = false
      else
        on_db = self.class.find_by(id: self.id)
        if on_db.present?
          saved_and_not_approved = !on_db.approved?
        else
          # skip notification if the record wasnt found
          saved_and_not_approved = false
        end
      end

      if saved_and_not_approved && self.approved?
        create_approval_notification
      end
    end

    # Starts the process of sending a notification to the model that was approved.
    def create_approval_notification
      create_activity 'approved', owner: proc { |controller|
        controller.try(:current_user)
      }, recipient: proc { |controller|
        controller.try(:current_user)
      }
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
