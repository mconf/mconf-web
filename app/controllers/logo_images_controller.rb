class LogoImagesController < ApplicationController
  def crop
    if params[:model_type] == 'user'
      @user = User.find_by_username(params[:model_id])
      @model = @user.profile!
      @url = user_profile_path(@user)
    end
    render :layout => false
  end
end
