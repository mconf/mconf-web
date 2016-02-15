class EventsController < InheritedResources::Base
  include Mconf::SelectControllerModule # for select method

  respond_to :html, :json

  # for ics renderer see config/initializers/renderers.rb
  respond_to :ics, only: :show

  before_filter :block_if_events_disabled
  before_filter :concat_datetimes, :only => [:create, :update]

  defaults finder: :find_by_permalink!
  load_and_authorize_resource find_by: :permalink

  before_filter :find_or_create_participant, only: [:show]

  # To help with timezone conversions in forms and displaying on the interface
  # Set this only in methods which use an '@event' instance variable
  before_filter :set_date_locale, if: -> { @event.present? }

  after_filter only: [:create, :update] do
    @event.new_activity params[:action], current_user unless @event.errors.any?
  end

  before_filter only: :index do
    filter_user_events
    filter_disabled_models
    search_events
    filter_by_scopes
    paginate
  end

  def new
    if params[:space_id].present?
      @event.owner = Space.find_by_permalink!(params[:space_id])
    else
      @event.owner = current_user
    end

    authorize! :new, @event

    new!
  end

  def create
    # TODO: make this better
    # Unfortunatelly this is here to prevent a bad request with 'owner_type' as an invalid class name
    # to raise a server error.
    begin
      if @event.owner.nil?
        @event.owner = current_user
      end
    rescue NameError
      @event.owner = nil
    end

    create!
  end

  def invite
    render layout: false if request.xhr?
  end

  def send_invitation
    if params[:invite][:title].blank?
      flash[:error] = t('events.send_invitation.error_title')

    elsif params[:invite][:users].blank?
      flash[:error] = t('events.send_invitation.blank_users')

    else
      invitations = EventInvitation.create_invitations params[:invite][:users],
        sender: current_user,
        target: @event,
        title: params[:invite][:title],
        url: @event.full_url,
        description: params[:invite][:message],
        ready: true

      # we do a check just to give a better response to the user, since the invitations will
      # only be sent in background later on
      succeeded, failed = EventInvitation.check_invitations(invitations)
      flash[:success] = EventInvitation.build_flash(
        succeeded, t('events.send_invitation.success')) unless succeeded.empty?
      flash[:error] = EventInvitation.build_flash(
        failed, t('events.send_invitation.error')) unless failed.empty?
    end
    redirect_to request.referer
  end

  private
  # Load the participant from db if user is already registered or build a new one for the form
  def find_or_create_participant
    if current_user
      attrs = { email: current_user.email, owner: current_user, event: @event }
      @participant = Participant.where(attrs).try(:first) || Participant.new(attrs)
    end
  end

  # return 404 for all Event routes if the events are disabled
  def block_if_events_disabled
    unless Mconf::Modules.mod_enabled?('events')
      raise ActionController::RoutingError.new('Not Found')
    end
  end

  def handle_access_denied(exception)
    if ['new', 'create'].include? action_name
      flash[:error] = t('flash.events.create.error')
      redirect_to events_path
    elsif @event.nil? || @event.owner.nil?
      raise ActiveRecord::RecordNotFound
    else
      raise exception
    end
  end

  def set_date_locale
    @time_zone = Time.zone
    @date_locale = get_user_locale(current_user)
    @date_format = I18n.t('_other.datetimepicker.format')
    @event.date_display_format = I18n.t('_other.datetimepicker.format_display')
  end

  # Filter events for the current user
  # If accessed with no logged in user, redirect to 'all events' path
  def filter_user_events

    if params[:my_events]
      if current_user
        @events = current_user.events
      else
        # Remove the parameter if no user is logged
        redirect_to events_path(params.except(:my_events))
        false # interrupt before filter chain
      end
    end
  end

  def filter_disabled_models
    # Filter events belonging to spaces or users with disabled status
    without_spaces =
      @events.where(owner_type: 'Space').joins('INNER JOIN spaces ON owner_id = spaces.id').where("spaces.disabled = ? && spaces.approved = ?", false, true)
    without_users =
      @events.where(owner_type: 'User').joins('INNER JOIN users ON owner_id = users.id').where("users.disabled = ? && users.approved = ?", false, true)

    @events = without_users.union(without_spaces)
  end

  # Use query parameter to search for events
  def search_events
    if params[:q].present?
      @events = @events.where("name like ?", "%#{params[:q]}%")
    end
  end

  def filter_by_scopes
    case params[:show]
    when 'happening_now'
      @events = @events.happening_now.order('start_on ASC')
    when 'past_events'
      @events = @events.past.order('start_on DESC')
    when 'all'
      @events = @events.order('start_on DESC')
    when 'upcoming_events', lambda{ |show| show.blank? } #default case
      @events = @events.upcoming.order('start_on ASC')

      # if there are no upcoming events and user accessed without parameters show all
      redirect_to events_path(:show => 'all') if @events.empty? && params[:show].blank?
    end

  end

  def paginate
    @events = @events.page(params[:page])
  end

  def concat_datetimes
    date_format = I18n.t('_other.datetimepicker.format_display')
    if params[:event][:time_zone].blank?
      params[:event][:time_zone] = Time.zone.name
    end

    [:start_on, :end_on].each do |field|
      if params[:event][field.to_s + '_date'].present?
        time = "#{params[:event][field.to_s + '_time(4i)']}:#{params[:event][field.to_s + '_time(5i)']}"
        params[:event][field] =
          Mconf::Timezone::parse_in_timezone(params[:event]["#{field}_date"], time, params[:event][:time_zone], date_format)
      end
      (1..5).each { |n| params[:event].delete("#{field}_time(#{n}i)") }
      params[:event].delete("#{field}_date")
    end
    true
  end

  def event_params
    params.require(:event).permit(
      :start_on, :start_on_time, :start_on_date,
      :end_on, :end_on_time, :end_on_date,
      :address, :description, :location, :name, :time_zone,
      :summary, :owner_id, :owner_type, :social_networks => []
    )
  end
end
