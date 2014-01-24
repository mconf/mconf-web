Rails.application.config.to_prepare do

  # Monkey patching events controller for pagination and recent activity
  MwebEvents::EventsController.class_eval do
    before_filter(:only => [:index]) do
      @events = @events.accessible_by(current_ability).paginate(:page => params[:page])
    end

    after_filter :only => [:create, :update] do
      @event.new_activity params[:action], current_user unless @event.errors.any?
    end

  end

  MwebEvents::Event.class_eval do
    include PublicActivity::Common

    def new_activity key, user
      create_activity key, :owner => owner, :parameters => { :user_id => user.id, :username => user.name }
    end

  end

end


