# Require Station Controller
require_dependency "#{ RAILS_ROOT }/vendor/plugins/translate/app/controllers/translate_controller"

class TranslateController
  
  include LocaleControllerModule
  before_filter :set_vcc_locale
  
  authorization_filter :tranlate, :site
  
  layout 'translate'
 
end