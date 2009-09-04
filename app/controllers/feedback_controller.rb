class FeedbackController < ApplicationController
  
 
  def new
    if request.xhr?
      render :layout => false
    end
  end
  
  def create
    if (params[:subject].present? and params[:from].present? and params[:body].present?)
      if (params[:from]).match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
        Notifier.deliver_feedback_email(params[:from],params[:subject], params[:body] )
        respond_to do |format|
          format.html {
            flash[:success] = t('feedback.sent')
            redirect_to root_path()
          }
        end
      else
        respond_to do |format|
          format.html {
            flash[:error] = t('check_mail')
            render :action => "new" 
          }
        end
      end
    else
      respond_to do |format|
        format.html {
          flash[:error] = t('fill_fields')
          render :action => "new" 
        }
      end
    end
  end
end