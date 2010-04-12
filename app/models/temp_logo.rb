require 'RMagick'

class TempLogo
  include Magick
  
  REL_TMP_PATH = File.join("tmp")
  ABS_TMP_PATH = File.join(RAILS_ROOT, "public", "images", REL_TMP_PATH)
  FORMAT = Mime::Type.lookup "image/png"
  MAX_SIZE = 600
  
  attr_accessor :logo_class, :owner
  
  class << self
    # Save a temp logo in a session
    def to_session(session, temp_logo)
      session[:temp_logo] = {:logo_class => temp_logo.logo_class.to_s,
                             :owner_class => temp_logo.owner.class.to_s,
                             :owner_id => temp_logo.owner.id
      }
    end
    
    #Restore a temp logo from a session
    def from_session(session)
      return nil unless session[:temp_logo].present?
      
      self.new(session[:temp_logo][:logo_class].constantize,
               session[:temp_logo][:owner_class].constantize.send(:find, session[:temp_logo][:owner_id])
      )
    end
  end

  # Create a temp logo. If object is not passed, it assumes temp file already exists
  def initialize(logo_class, owner, object=nil)
    @logo_class, @owner = logo_class, owner
    
    if object.present?
      temp_file = File.open(File.join(ABS_TMP_PATH,temp_filename), "w+")
      temp_file.write(object['media'].read)
      temp_file.close
      
      reshape_image temp_path, @logo_class::ASPECT_RATIO_F
      resize_if_bigger temp_path, MAX_SIZE
    end
  end
    
  def image
    File.join(REL_TMP_PATH,temp_filename)
  end

  def temp_path
    File.join(ABS_TMP_PATH,temp_filename)
  end
  
  def temp_filename
    "precrop-#{@logo_class.name.downcase}-#{@owner.id}.#{FORMAT.to_sym.to_s}"
  end
  
  def server_filename
    "#{@owner.permalink}.#{FORMAT.to_sym.to_s}"
  end
  
  # Crop and resize the temp file and returns the image as the :media value in a hash
  def crop_and_resize crop_params
      
    img = Magick::Image.read(File.open(File.join(ABS_TMP_PATH,temp_filename))).first

    crop_args = %w( x y width height ).map{ |k| crop_params[k] }.map(&:to_i)
    crop_img = img.crop(*crop_args)
    f = ActionController::UploadedTempfile.open("croplogo","tmp")
    crop_img.write("#{FORMAT.to_sym.to_s}:" + f.path)
    f.instance_variable_set "@original_filename", server_filename
    f.instance_variable_set "@content_type", FORMAT
    logo = {}
    logo[:media] = f
    logo
  end
  
  private

  def resize_if_bigger path, size
    
    f = File.open(path)
    img = Magick::Image.read(f).first
    if img.columns > img.rows && img.columns > size
      resized = img.resize(size.to_f/img.columns.to_f)
      f.close
      resized.write("#{FORMAT.to_sym.to_s}:" + path)
    elsif img.rows > img.columns && img.rows > size
      resized = img.resize(size.to_f/img.rows.to_f)
      f.close
      resized.write("#{FORMAT.to_sym.to_s}:" + path)
    end
    
  end
  
  def reshape_image path, aspect_ratio
    
    f = File.open(path)
    img = Magick::Image.read(f).first
    aspect_ratio_orig = (img.columns / 1.0) / (img.rows / 1.0) 
    if aspect_ratio_orig < aspect_ratio
      # target image is more 'horizontal' than original image
      target_size_y = img.rows
      target_size_x = target_size_y * aspect_ratio
    else
      # target image is more 'vertical' than original image
      target_size_x = img.columns
      target_size_y = target_size_x / aspect_ratio
    end
    # We center the image inside the white canvas
    decenter_x = -(target_size_x - img.columns) / 2;
    decenter_y = -(target_size_y - img.rows) / 2;
    
    reshaped = img.extent(target_size_x, target_size_y, decenter_x, decenter_y)
    f.close
    reshaped.write("#{FORMAT.to_sym.to_s}:" + path)
    
  end
  
end