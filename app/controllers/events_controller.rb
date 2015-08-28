class EventsController < ApplicationController
  before_filter :concat_datetimes, :only => [:create, :update]
  load_and_authorize_resource :find_by => :permalink
  before_filter :set_date_locale, if: -> { @event.present? }

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

  def set_date_locale
    # can be overriden by the application
    @date_locale = 'en'
    @date_format = 'MM-dd-yyyy'
    @event.date_stored_format = '%m/%d/%Y %H:%M'
    @event.date_display_format = '%m/%d/%Y'
  end

  def event_params
    params.require(:event).permit(
      :address, :description, :start_on, :end_on, :location, :name, :time_zone,
      :summary, :owner_id, :owner_type, :date_stored_format, :social_networks => []
    )
  end
end
