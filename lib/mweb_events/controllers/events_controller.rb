MwebEvents::EventsController.class_eval do

  before_filter :block_if_events_disabled
  before_filter :custom_loading, :only => [:index]
  before_filter :create_participant, :only => [:show]

  after_filter :only => [:create, :update] do
    @event.new_activity params[:action], current_user unless @event.errors.any?
  end

  def invite
    @event = MwebEvents::Event.find_by_permalink(params[:event_id])
    authorize! :invite, @event
  end

  def send_invitation
    @event = MwebEvents::Event.find_by_permalink(params[:event_id])
    authorize! :send_invitation, @event

    # the invitation object to be sent
    invitation = Mconf::EventInvitation.new
    invitation.mailer = EventMailer
    invitation.from = current_user
    invitation.event = @event
    invitation.title = params[:invite][:title]
    invitation.url = @event.full_url
    invitation.description = params[:invite][:message]

    # send the invitation to all users
    # make `users` an array of Users and emails
    users = Mconf::Invitation.split_invitations(params[:invite][:users])
    succeeded, failed = Mconf::Invitation.send_batch(invitation, users)

    unless succeeded.empty?
      success_msg = t('mweb_events.events.send_invitation.success') + " "
      success_msg += succeeded.map { |user|
        user.is_a?(User) ? user.full_name : user
      }.join(", ")
      flash[:success] = success_msg
    end
    unless failed.empty?
      error_msg = t('mweb_events.events.send_invitation.error') + " "
      error_msg += failed.map { |user|
        user.is_a?(User) ? user.full_name : user
      }.join(", ")
      flash[:error] = error_msg
    end

    respond_to do |format|
      format.html { redirect_to request.referer }
    end
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
    @events = @events.accessible_by(current_ability, :index).paginate(:page => params[:page])
  end
end
