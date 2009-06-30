
module SpamControllerModule 
   
  def spam
    @spam = resource
    @spam.update_attribute(:spam, true)
      if @spam.save
        Notifier.deliver_spam_email(current_user.email,"New Spam Detected", params[:body] )
        respond_to do |format|
          format.html {
            flash[:success] = "A reporting spam e-mail has been successfully sent to the admin off the VCC. Thanks you"
            redirect_to request.referer
          }
        end
      else
        respond_to do |format|
          format.html {
            flash[:error] = "there was a problem checking the resource as spam"
            render :action => "new" 
          }
        end
      end
  end
  
  def spam_lightbox
    resource
    if request.xhr?
      render :layout => false
    end
  end
 
end