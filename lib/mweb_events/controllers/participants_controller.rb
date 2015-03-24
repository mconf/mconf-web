MwebEvents::ParticipantsController.class_eval do
  before_filter :block_if_events_disabled
  before_filter :custom_loading, only: [:index]

  after_filter only: [:create] do
    @participant.new_activity(params[:action], current_user) if @participant.persisted?
  end
  after_filter :waiting_for_confirmation_message, only: [:create]

  layout "no_sidebar", only: [:new]

  # return 404 for all Participant routes if the events are disabled
  def block_if_events_disabled
    unless Mconf::Modules.mod_enabled?('events')
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def custom_loading
    @participants = @participants.accessible_by(current_ability)
      .order(['owner_id desc', 'created_at desc'])
      .paginate(:page => params[:page])
  end

  private

  def handle_access_denied(exception)
    if @event.owner.nil?
      raise ActiveRecord::RecordNotFound
    else
      raise exception
    end
  end

  def waiting_for_confirmation_message
    if @participant.persisted? && !@participant.email_confirmed?
      flash[:notice] = t('mweb_events.participants.create.waiting_confirmation')
    end
  end
end
