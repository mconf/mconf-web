class EventsController < ApplicationController
  before_filter :concat_datetimes, :only => [:create, :update]
  load_and_authorize_resource :find_by => :permalink
  before_filter :set_date_locale, if: -> { @event.present? }

  before_filter :block_if_events_disabled
  before_filter :custom_loading, only: [:index]
  before_filter :find_or_create_participant, only: [:show]

  after_filter only: [:create, :update] do
    @event.new_activity params[:action], current_user unless @event.errors.any?
  end

  respond_to :html, :json

  def index

    if params[:show] == 'happening_now'
      @events = @events.happening_now.order('start_on ASC')
    elsif params[:show] == 'past_events'
      @events = @events.past.order('start_on DESC')
    elsif params[:show] == 'all'
      @events = @events.order('start_on DESC')
    elsif params[:show] == 'upcoming_events' || params[:show].blank? #default case
      @events = @events.upcoming.order('start_on ASC')

      # if there are no upcoming events and user accessed without parameters show all
      redirect_to events_path(:show => 'all') if @events.empty? && params[:show].blank?
      return
    end

    # Use query parameter to search for events
    if params[:q].present?
      @events = @events.where("name like ?", "%#{params[:q]}%")
    end
  end

  def show
    @time_zone = Time.zone

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }

      format.ics do
        calendar = Icalendar::Calendar.new
        calendar.add_event(@event.to_ics)
        calendar.publish
        render :text => calendar.to_ical
      end

    end
  end

  def new
    if params[:owner_id] && params[:owner_type]
      @event.owner_id = params[:owner_id]
      @event.owner_type = params[:owner_type]
    else
      @event.owner_name = current_user.try(:email)
    end
  end

  def edit
  end

  def create
    @event = Event.new(event_params)

    if @event.owner.nil?
      @event.owner = current_user
    end

    respond_to do |format|
      if @event.save
        format.html { redirect_to @event, notice: t('mweb_events.event.created') }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @event.update_attributes(event_params)
        format.html { redirect_to @event, notice: t('mweb_events.event.updated') }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @event.destroy

    respond_to do |format|
      format.html { redirect_to events_url, notice: t('mweb_events.event.destroyed') }
    end
  end

  # Finds events by name (params[:q]) and returns a list of selected attributes
  def select
    name = params[:q]
    limit = params[:limit] || 5
    limit = 50 if limit.to_i > 50
    if name.blank?
      @events = Event.limit(limit).all
    else
      @events = Event.where("name like ?", "%#{name}%").limit(limit)
    end
  end

  def invite
    render layout: false if request.xhr?
  end

  def send_invitation
    if params[:invite][:title].blank?
      flash[:error] = t('mweb_events.events.send_invitation.error_title')

    elsif params[:invite][:users].blank?
      flash[:error] = t('mweb_events.events.send_invitation.blank_users')

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
        succeeded, t('mweb_events.events.send_invitation.success')) unless succeeded.empty?
      flash[:error] = EventInvitation.build_flash(
        failed, t('mweb_events.events.send_invitation.error')) unless failed.empty?
    end
    redirect_to request.referer
  end

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
    without_spaces = @events.where(owner_type: 'Space').joins('INNER JOIN spaces ON owner_id = spaces.id').where("spaces.disabled = ?", false)
    without_users = @events.where(owner_type: 'User').joins('INNER JOIN users ON owner_id = users.id').where("users.disabled = ?", false)
    # If only there was a conjunction operator that returned an AR relation, this would be easier
    # '|'' is the only one that corretly combines these two queries, but doesn't return a relation
    @events = Event.where(id: (without_users | without_spaces))
    @events = @events.accessible_by(current_ability, :index).page(params[:page])
  end

  def handle_access_denied(exception)
    if @event.nil? || @event.owner.nil?
      raise ActiveRecord::RecordNotFound
    else
      raise exception
    end
  end

  def set_date_locale
    @date_locale = get_user_locale(current_user)
    @date_format = I18n.t('_other.datetimepicker.format')
    @event.date_stored_format = I18n.t('_other.datetimepicker.format_rails')
    @event.date_display_format = I18n.t('_other.datetimepicker.format_display')
  end

  private
  def concat_datetimes
    date_format = I18n.t('_other.datetimepicker.format_display')

    [:start_on, :end_on].each do |field|
      if params[:event][field.to_s + '_date']
        time = "#{params[:event][field.to_s + '_time(4i)']}:#{params[:event][field.to_s + '_time(5i)']}"
        params[:event][field] =
          parse_in_timezone(params[:event]["#{field}_date"], time, params[:event][:time_zone], date_format)
      end
      (1..5).each { |n| params[:event].delete("#{field}_time(#{n}i)") }
      params[:event].delete("#{field}_date")
    end
    true
  end

  def event_params
    params.require(:event).permit(
      :address, :description, :start_on, :end_on, :location, :name, :time_zone,
      :summary, :owner_id, :owner_type, :date_stored_format, :social_networks => []
    )
  end
end
