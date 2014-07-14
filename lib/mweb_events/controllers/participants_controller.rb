MwebEvents::ParticipantsController.class_eval do
  before_filter :block_if_events_disabled
  before_filter :custom_loading, :only => [:index]

  after_filter :only => [:create] do
    @participant.new_activity params[:action], current_user if @participant.persisted?
  end

  layout "no_sidebar", :only => [:new]

  # return 404 for all Participant routes if the events are disabled
  def block_if_events_disabled
    unless Mconf::Modules.mod_enabled?('events')
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def custom_loading
    @participants = @participants.accessible_by(current_ability).paginate(:page => params[:page])
  end
end
