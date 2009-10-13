
module SpamControllerModule 
   
  def spam
    @spam = resource
    @spam.update_attribute(:spam, true)
      if @spam.save
        Notifier.deliver_spam_email(current_user,t('spam.detected'), params[:body] )
        respond_to do |format|
          format.html {
            flash[:success] = t('spam.created')
            redirect_to request.referer
          }
        end
      else
        respond_to do |format|
          format.html {
            flash[:error] = t('spam.error.check')
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