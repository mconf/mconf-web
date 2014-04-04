Rails.application.config.to_prepare do

  if defined?(MwebEvents)
    configatron.modules.events.loaded = true
  end

  if configatron.modules.events.loaded

    # Monkey patching events controller for pagination and recent activity
    MwebEvents::EventsController.class_eval do

      # return 404 for all Event routes if the events are disable
      before_filter do
        unless Mconf::Modules.mod_enabled?('events')
          raise ActionController::RoutingError.new('Not Found')
        end
      end

      before_filter(:only => [:index]) do
        # Filter events for the current user
        @events = current_user.events if params[:my_events]

        # Filter events belonging to spaces or users with disabled status
        without_spaces = @events.where(:owner_type => 'Space').joins('INNER JOIN spaces ON owner_id = spaces.id').where("spaces.disabled = false")
        without_users = @events.where(:owner_type => 'User').joins('INNER JOIN users ON owner_id = users.id').where("users.disabled = false")
        # If only there was a conjunction operator that returned an AR relation, this would be easier
        # '|'' is the only one that corretly combines these two queries, but doesn't return a relation
        @events = MwebEvents::Event.where(:id =>(without_users | without_spaces))
        @events = @events.accessible_by(current_ability, :index).page(params[:page])
      end

      after_filter :only => [:create, :update] do
        @event.new_activity params[:action], current_user unless @event.errors.any?
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
          owner.public?
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

      # return 404 for all Participant routes if the events are disable
      before_filter do
        unless Mconf::Modules.mod_enabled?('events')
          raise ActionController::RoutingError.new('Not Found')
        end
      end

      before_filter(:only => [:index]) do
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

    MwebEvents::EventsHelper.instance_eval do
      def build_message_path(participant)
        main_app.new_message_path(
         :user_id => current_user.to_param, :receiver => participant.owner.id,
         :private_message => { :title => t('mweb_events.participants.index.event', :event => participant.event.name) }
        )
      end
    end

  end

end
