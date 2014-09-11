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
    respond_to do |format|
      format.html {
        render :layout => false if request.xhr?
      }
    end
  end

  def send_invitation
    @event = MwebEvents::Event.find_by_permalink(params[:event_id])
    authorize! :send_invitation, @event

    invitation_params = {
      :sender => current_user,
      :target => @event,
      :title => params[:invite][:title],
      :url => @event.full_url,
      :description => params[:invite][:message],
      :ready => true
    }

    # creates an invitation for each user
    invitations = []
    users = Invitation.split_invitation_senders(params[:invite][:users])
    users.each do |user|
      if user.is_a? String
        invitation_params[:recipient_email] = user
      else
        invitation_params[:recipient] = User.find_by_id(user)
      end
      invitations << EventInvitation.create(invitation_params)
    end

    # we do a check just to give a better response to the user, since the invitations will
    # only be sent in background later on
    succeeded, failed = Invitation.check_invitations(invitations)
    flash[:success] = Invitation.build_flash(
      succeeded, t('mweb_events.events.send_invitation.success')) unless succeeded.empty?
    flash[:error] = Invitation.build_flash(
      failed, t('mweb_events.events.send_invitation.errors')) unless failed.empty?

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
        return
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

  def set_date_locale
    @date_locale = get_user_locale(current_user)
    @date_format = I18n.t('_other.datetimepicker.format')
    @event.date_stored_format = I18n.t('_other.datetimepicker.format_rails')
    @event.date_display_format = I18n.t('_other.datetimepicker.format_display')
  end

end
