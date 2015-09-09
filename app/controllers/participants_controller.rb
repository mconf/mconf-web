class ParticipantsController < ApplicationController
  load_and_authorize_resource :event, :find_by => :permalink
  load_and_authorize_resource :participant, :through => :event

  before_filter :block_if_events_disabled
  before_filter :custom_loading, only: [:index]

  after_filter only: [:create] do
    @participant.new_activity(params[:action], current_user) if @participant.persisted?
  end
  after_filter :waiting_for_confirmation_message, only: [:create]

  layout "no_sidebar", only: [:new]

  def index
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @participants }
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @participant }
    end
  end

  def new
    email = current_user && current_user.email
    @participant.email = email

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @participant }
    end
  end

  def edit
  end

  def create
    @participant.event = @event
    if current_user
      @participant.owner = current_user
      @participant.email = current_user.email
    end
    respond_to do |format|
      # If user is already registered with this email succeed with another message and don't save
      taken = @participant.email_taken?
      notice = taken ? t('mweb_events.participant.already_created') : t('mweb_events.participant.created')
      if taken || @participant.save
        format.html { redirect_to @event, notice: notice }
        format.json { render json: @participant, status: :created, location: @participant }
      else
        format.html { render action: "new" }
        format.json { render json: @participant.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @participant.destroy

    respond_to do |format|
      path = can?(:update, @event) ? :back : event_path(@event)
      format.html { redirect_to path, notice: t('mweb_events.participant.destroyed') }
      format.json { head :no_content }
    end
  end

  private
  def participant_params
    params.require(:participant).permit(:email, :event, :event_id, :owner, :owner_id)
  end

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
