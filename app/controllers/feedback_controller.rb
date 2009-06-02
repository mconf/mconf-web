class FeedbackController < ApplicationController
  
 
  def new
    if request.xhr?
      render :layout => false
    end
  end
  
  def create
    if (params[:feedback][:subject].present? and params[:feedback][:from].present? and params[:feedback][:body].present?)
      Notifier.deliver_feedback_email(params[:feedback][:from],params[:feedback][:subject], params[:feedback][:body] )
      respond_to do |format|
        format.html {
          flash[:success] = "your feedback information e-mail has been successfully sent. Thanks you"
          redirect_to root_path()
        }
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = "you should fill in all the fields"
          render :action => "new" 
        }
      end
    end
  end
end