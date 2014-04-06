Rails.application.config.to_prepare do

  if defined?(MwebEvents)
    configatron.modules.events.loaded = true
  end

  if configatron.modules.events.loaded

    # Monkey patching events controller for pagination and recent activity
    MwebEvents::EventsController.class_eval do

      before_filter :block_if_events_disabled
      before_filter :custom_loading, :only => [:index]
      before_filter :create_participant, :only => [:show]

      after_filter :only => [:create, :update] do
        @event.new_activity params[:action], current_user unless @event.errors.any?
      end

      def create_participant
        @participant = @event.participants.build :email => current_user.email, :owner => current_user if current_user
      end

      # return 404 for all Event routes if the events are disabled
      def block_if_events_disabled
        unless Mconf::Modules.mod_enabled?('events')
          raise ActionController::RoutingError.new('Not Found')
        end
      end

      def custom_loading
        # Filter events for the current user
        if params[:my_events]
          if current_user
            @events = current_user.events
          else # Remove the parameter if no user is logged
            redirect_to events_path(params.except(:my_events))
          end
        end

        # Filter events belonging to spaces or users with disabled status
        without_spaces = @events.where(:owner_type => 'Space').joins('INNER JOIN spaces ON owner_id = spaces.id').where("spaces.disabled = false")
        without_users = @events.where(:owner_type => 'User').joins('INNER JOIN users ON owner_id = users.id').where("users.disabled = false")
        # If only there was a conjunction operator that returned an AR relation, this would be easier
        # '|'' is the only one that corretly combines these two queries, but doesn't return a relation
        @events = MwebEvents::Event.where(:id =>(without_users | without_spaces))
        @events = @events.accessible_by(current_ability, :index).page(params[:page])
      end
    end

    MwebEvents::Event.class_eval do
      include PublicActivity::Common

      def new_activity key, user
        create_activity key, :owner => owner, :parameters => { :user_id => user.try(:id), :username => user.try(:name) }
      end

      # Temporary while we have no private events
      def public
        if owner_type == 'User'
          true # User owned spaces are always public
        elsif owner_type == 'Space'
          owner && owner.public?
        end
      end

      # alias :old_owner :owner
      # def owner
      #   Space.unscoped do
      #     old_owner
      #   end
      # end

    end

    # Same for participants, public activity is still missing
    MwebEvents::ParticipantsController.class_eval do
      before_filter :block_if_events_disabled
      before_filter :custom_loading, :only => [:index]

      # return 404 for all Participant routes if the events are disabled
      def block_if_events_disabled
        unless Mconf::Modules.mod_enabled?('events')
          raise ActionController::RoutingError.new('Not Found')
        end
      end

      def custom_loading
        @participants = @participants.accessible_by(current_ability).paginate(:page => params[:page])
      end

      after_filter :only => [:create] do
        @participant.new_activity params[:action], current_user unless @participant.errors.any?
      end
    end

    MwebEvents::Participant.class_eval do
      include PublicActivity::Common

      def new_activity key, user
        create_activity key, :owner => owner, :parameters => { :user_id => user.try(:id), :username => user.try(:name) }
      end
    end

    MwebEvents::EventsHelper.class_eval do
      def build_message_path(participant)
        main_app.new_message_path(
         :user_id => current_user.to_param, :receiver => participant.owner.id,
         :private_message => { :title => t('mweb_events.participants.index.event', :event => participant.event.name) }
        )
      end
    end

  end

end
