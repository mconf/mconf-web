class ParticipantConfirmationsController < ApplicationController

  def confirm
    @pc = ParticipantConfirmation.where(token: params[:token]).first
    @pc.confirm!
    redirect_to mweb_events.event_path(@pc.participant.event), notice: t('participant_confirmation.confirmed', email: @pc.participant.email)
  end

end
