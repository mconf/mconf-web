class ParticipantConfirmationsController < ApplicationController

  before_filter :find_by_token

  def confirm
    @pc.confirm!
    redirect_to mweb_events.event_path(@pc.participant.event), notice: t('participant_confirmation.confirmed', email: @pc.participant.email)
  end

  def destroy
    @pc.destroy
    redirect_to mweb_events.event_path(@pc.participant.event), notice: t('participant_confirmation.cancelled')
  end

  private
  def find_by_token
    @pc = ParticipantConfirmation.where(token: params[:token]).first
  end
end
