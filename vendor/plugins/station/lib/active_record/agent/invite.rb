module ActiveRecord #:nodoc:
  module Agent
    # Support for Agent for being invited.
    #
    # Invitations can be made to the Application, or/and to a particular Stage and Role
    #
    module Invite
      class << self
        # All classes supporting Invitation
        def classes
          ActiveRecord::Agent.classes.select{ |a| a.agent_options[:invite] }
        end

        # Find all Agent instances by invitation key
        def find_all(key)
          classes.map{ |klass|
            klass.send "find_all_by_#{ klass.agent_options[:invite] }", key
          }.flatten.uniq
        end

        def included(base) #:nodoc:
          base.class_eval do
            has_many :pending_invitations,
                     :class_name => "Invitation",
                     :as => :candidate

            after_create "assign_pending_invitations"
          end
        end
      end

      private

      # Update Invitations with this candidate
      def assign_pending_invitations #:nodoc:
        key = send(agent_options[:invite])

        Invitation.find_all_by_email(key).map{ |i| i.update_attribute(:candidate, self) }
      end
    end
  end
end
