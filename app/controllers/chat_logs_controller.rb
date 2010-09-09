class ChatLogsController < ApplicationController
  
  def show
    chat_log = Event.find_with_param(params[:event_id]).chat_log
    content = chat_log.content
    
    respond_to do |format|
      format.text do
        render :text => content, :content_type => "text/plain"
      end
    end
  end
  
end
