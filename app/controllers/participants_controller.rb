class ParticipantsController < ApplicationController
  
  def update
    
    @participant = Participant.find(params[:id])
    debugger
    if @participant.update_attributes(params[:participant])
      respond_to do |format|
      format.html {
      flash[:success] = "your event participation has been successfully updated"
        redirect_to request.referer
      }
      end
    else
      message = ""
      @participant.errors.full_messages.each {|msg| message += msg + "  <br/>"}
      flash[:error] = message
      redirect_to request.referer
    end
  end
  
end