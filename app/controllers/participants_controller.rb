class ParticipantsController < ApplicationController
  
  
  def create

    @participant = Participant.new(params[:participant])
    @participant.event_id = params[:event_id]
    @participant.user = current_user
    @participant.email = current_user.email
    if @participant.save    
      respond_to do |format|
      format.html {
      flash[:success] = t('participant.created')
        redirect_to request.referer
      }
      format.js
    end
  else
      flash[:error] = t('participant.error.create')
      redirect_to request.referer    
  end
end
  
  def update
    @participant = Participant.find(params[:id])
    if @participant.update_attributes(params[:participant])
      respond_to do |format|
      format.html {
      flash[:success] = t('participant.created')
      redirect_to request.referer
      }

      end
    else
      flash[:error] = t('participant.error.create')
      redirect_to request.referer
    end
  end
  
end