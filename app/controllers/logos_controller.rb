# Require Station Controller
require_dependency "#{ RAILS_ROOT }/vendor/plugins/station/app/controllers/logos_controller"
require 'RMagick'

class LogosController
  include Magick
  
  TMP_PATH = File.join(RAILS_ROOT, "public", "images", "tmp")
  
  def precrop
    if params['logo']['media'].blank?
      redirect_to request.referer
      return
    end
    
    @space = Space.find(params[:space_id])
    @logo = @space.logo || Logo.new 

    f = File.open(File.join(TMP_PATH,"precroplogo-#{@space.id}"), "w+")
    f.write(params['logo']['media'].read)
    f.close
    @image = "tmp/" + File.basename(f.path)
    session[:tmp_logo] = {}
    session[:tmp_logo][:basename] = File.basename(f.path)
    session[:tmp_logo][:original_filename] = params['logo']['media'].original_filename
    session[:tmp_logo][:content_type] = params['logo']['media'].content_type


    resize_if_bigger f.path, 600 
    
    render :layout => false

   
  end
  
  def create
    space = Space.find(params[:space_id])
    if params[:crop_size].present?
      crop_and_resize
    end
    @logo = space.build_logo(params[:logo])
    if @logo.save
      flash[:success] = "Logo created successfully"
      redirect_to edit_space_path(space)
    else
      flash[:error] = "Error. " + @logo.errors.to_xml
      redirect_to edit_space_path(space)
    end
    
  end
  
  def update
    space = Space.find(params[:space_id])
    if params[:crop_size].present?
      crop_and_resize
    end
    @logo = space.logo
    if @logo.update_attributes(params[:logo])
      flash[:success] = "Logo created successfully"
      redirect_to edit_space_path(space)
    else
      flash[:error] = "Error. " + @logo.errors.to_xml
      redirect_to edit_space_path(space)
    end   
  end
  
  private

  def crop_and_resize 
      
    img = Magick::Image.read(File.open(File.join(TMP_PATH,session[:tmp_logo][:basename]))).first

    crop_args = %w( x y width height ).map{ |k| params[:crop_size][k] }.map(&:to_i)
    crop_img = img.crop(*crop_args)
    f = ActionController::UploadedTempfile.open ("croplogo","tmp")
    crop_img.write("png:" + f.path)
    f.instance_variable_set "@original_filename",session[:tmp_logo][:original_filename]
    f.instance_variable_set "@content_type", session[:tmp_logo][:content_type]
    params[:logo] ||= {}
    params[:logo][:media] = f

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