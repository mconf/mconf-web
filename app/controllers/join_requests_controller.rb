# Require Station Controller
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/controllers/join_requests_controller"

class JoinRequestsController
  before_filter :space

  def new
    respond_to do |format|
      format.html{
        if request.xhr?
          render :layout => false
        end
      }
    end
  end

  def create
    unless authenticated?
      unless params[:user]
        respond_to do |format|
          format.html {
            render :action => 'new'
          }
          format.js
        end
        return
      end

      if params[:register]
        cookies.delete :auth_token
        @user = User.new(params[:user])
        unless @user.save_with_captcha
          message = ""
          @user.errors.full_messages.each {|msg| message += msg + "  <br/> "}
          flash[:error] = message
          respond_to do |format|
            format.html {
              render :action => 'new'
            }
            format.js
          end
          return
        end
      end

      self.current_agent = User.authenticate_with_login_and_password(params[:user][:email], params[:user][:password])
      unless logged_in?
        flash[:error] = t('error.credentials')
        respond_to do |format|
          format.html {
            render :action => 'new'
          }
          format.js
        end
        return
      end
    end

    if space.users.include?(current_agent)
      flash[:notice] = t('join_request.joined')
      if request.xhr?
        render :partial=> "redirect.js.erb", :locals => {:url => space_path(space)}
      else
        redirect_to space
      end
      return
    end

    @join_request = space.join_requests.new
    @join_request.candidate = current_user

    if @join_request.save
      flash[:notice] = t('join_request.created')
    else
      flash[:notice] = t('join_request.already_sent')
      #flash[:error] = jr.errors.to_xml
    end

    if request.xhr?
        render :partial => "redirect.js.erb", :locals => {:url => spaces_path}
      else
        redirect_to spaces_path  
    end
  end
 
end
