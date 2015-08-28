class ParticipantsController < ApplicationController
  load_and_authorize_resource :event, :find_by => :permalink
  load_and_authorize_resource :participant, :through => :event

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

end
