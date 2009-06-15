class FeedbackController < ApplicationController
  
 
  def new
    if request.xhr?
      render :layout => false
    end
  end
  
  def create
    if (params[:feedback][:subject].present? and params[:feedback][:from].present? and params[:feedback][:body].present?)
      if (params[:feedback][:from]).match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
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
            flash[:error] = "please, check your email"
            render :action => "new" 
          }
        end
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