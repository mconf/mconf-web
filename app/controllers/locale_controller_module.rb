module LocaleControllerModule
  def set_vcc_locale
    if Rails.env == "production" && !current_site.authorizes? (:translate, :to => current_user)
      I18n.locale = I18n.default_locale
    else
      if logged_in? && current_user.locale.present? && I18n.available_locales.include?(current_user.locale.to_sym)
        I18n.locale = current_user.locale.to_sym
      elsif session[:locale] and I18n.available_locales.include?(session[:locale])
        I18n.locale = session[:locale]
      elsif accept_language_header_locale and I18n.available_locales.include?(accept_language_header_locale)
        I18n.locale = accept_language_header_locale
      else
        I18n.locale = I18n.default_locale  
      end
    end
  end
end
