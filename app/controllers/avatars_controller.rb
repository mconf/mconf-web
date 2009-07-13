require 'RMagick'

class AvatarsController < ApplicationController
  include Magick
  
  TMP_PATH = File.join(RAILS_ROOT, "public", "images", "tmp")
  
  def precrop
    if params['avatar']['media'].blank?
      redirect_to request.referer
      return
    end
    
    @user = User.find(params[:user_id])
    @avatar = @user.profile!.logo || Avatar.new 

    f = File.open(File.join(TMP_PATH,"precropavatar-#{@user.id}"), "w+")
    f.write(params['avatar']['media'].read)
    f.close
    @image = "tmp/" + File.basename(f.path)
    session[:tmp_avatar] = {}
    session[:tmp_avatar][:basename] = File.basename(f.path)
    session[:tmp_avatar][:original_filename] = params['avatar']['media'].original_filename
    session[:tmp_avatar][:content_type] = params['avatar']['media'].content_type


    resize_if_bigger f.path, 600 
    
    render :layout => false

   
  end
  
  def create
    user = User.find(params[:user_id])
    if params[:crop_size].present?
      crop_and_resize
    end
    @avatar = user.profile!.build_logo(params[:avatar])
    if @avatar.save
      flash[:success] = "Avatar created successfully"
      redirect_to user_profile_path(user)
    else
      flash[:error] = "Error. " + @avatar.errors.to_xml
      redirect_to user_profile_path(user)
    end
    
  end
  
  def update
     user = User.find(params[:user_id])
    if params[:crop_size].present?
      crop_and_resize
    end
    @avatar = user.profile
    if @avatar.logo.update_attributes(params[:avatar])
      flash[:success] = "Avatar created successfully"
      redirect_to user_profile_path(user)
    else
      flash[:error] = "Error. " + @avatar.logo.errors.to_xml
      redirect_to user_profile_path(user)
    end   
  end
  
  private

  def crop_and_resize 
      
    img = Magick::Image.read(File.open(File.join(TMP_PATH,session[:tmp_avatar][:basename]))).first

    crop_args = %w( x y width height ).map{ |k| params[:crop_size][k] }.map(&:to_i)
    crop_img = img.crop(*crop_args)
    f = ActionController::UploadedTempfile.open ("cropavatar","tmp")
    crop_img.write("png:" + f.path)
    f.instance_variable_set "@original_filename",session[:tmp_avatar][:original_filename]
    f.instance_variable_set "@content_type", session[:tmp_avatar][:content_type]
    params[:avatar] ||= {}
    params[:avatar][:media] = f

  end

  def resize_if_bigger path, size
    
    f = File.open(path)
    img = Magick::Image.read(f).first
    if img.columns > img.rows && img.columns > size
      resized = img.resize(size.to_f/img.columns.to_f)
      f.close
      resized.write("png:" + path)
    elsif img.rows > img.columns && img.rows > size
      resized = img.resize(size.to_f/img.rows.to_f)
      f.close
      resized.write("png:" + path)
    end
    
  end
  
end