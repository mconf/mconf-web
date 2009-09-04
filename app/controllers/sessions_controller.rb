# Require Station Controller
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/controllers/sessions_controller"

class SessionsController
  # Don't render Station layout, use application layout instead
  layout 'application'

  # render new.rhtml
  def new
    if logged_in?
      flash[:error] = t('session.error.exist')
      redirect_to root_path
      return
    end

    # See ActionController::Sessions#authentication_methods_chain 
    authentication_methods_chain(:new)
    
    respond_to do |format|
      if request.xhr?
        format.js {
          render :partial => "sessions/login" 
        }
      end
      format.html
    end
  end

  private

  def after_create_path
    if current_user.superuser == true && Site.current.new_record?
      flash[:notice] = t('session.error.fill')
      edit_site_path
    elsif !current_user.profile
      flash[:notice]= t('session.should_create', :path => new_user_profile_path(current_user))  
      spaces_path
    else
    spaces_path
    end
  end

  def after_destroy_path
    root_path
  end
end
