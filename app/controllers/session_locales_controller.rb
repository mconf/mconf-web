class SessionLocalesController < ActionController::Base
  
  def create
    new_locale = params[:new_locale].to_sym
    
    if I18n.available_locales.include?(new_locale)
    
      #Add locale to the session
      session[:locale] =  new_locale 
    
      #Add locale to the user profile
      if logged_in?
        current_user.update_attribute(:locale, params[:new_locale])
      end

      flash[:success] = t('locale.changed') + params[:new_locale] 

    else
    
      flash[:error] = t('locale.error') + params[:new_locale]
    
    end
  
    redirect_to request.referer
    
  end
  
end