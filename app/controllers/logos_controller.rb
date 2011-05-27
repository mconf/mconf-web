# -*- coding: utf-8 -*-
# Copyright 2008-2010 Universidad Politécnica de Madrid and Agora Systems S.A.
#
# This file is part of VCC (Virtual Conference Center).
#
# VCC is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# VCC is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with VCC.  If not, see <http://www.gnu.org/licenses/>.

# Require Station Controller
require_dependency "#{ Rails.root.to_s }/vendor/plugins/station/app/controllers/logos_controller"
require 'RMagick'

class LogosController
  include Magick

  REL_TMP_PATH = File.join("tmp")
  ABS_TMP_PATH = File.join(Rails.root.to_s, "public", "images", REL_TMP_PATH)
  FORMAT = Mime::Type.lookup "image/png"

  def new
    if params[:text]
      if params[:text].eql? ""
        params[:text] = " "
      end

      for i in 1..5
        create_auto_logo params[:text], i, params[:event_logo].present?
      end
      if params[:event_logo].present?
        render :template => "events/_generate_text_logos", :layout => false
      else
        render :template => "spaces/_generate_text_logos", :layout => false
      end
   end

   if params[:upload]

     images_path = File.join(Rails.root.to_s, "public", "images")
     tmp_path = File.join(images_path, "tmp")
     final_path = FileUtils.mkdir_p(tmp_path + "/#{params[:logo][:rand]}")
     uploaded_image = File.join(final_path, "uploaded_logo.png")

     temp_file = File.open(uploaded_image, "wb")
     temp_file.write(params[:logo][:media].read)
     temp_file.close
     TempLogo.reshape_image uploaded_image, Logo::ASPECT_RATIO_F
     img_orig = Magick::Image.read(uploaded_image).first
     img_orig = img_orig.resize_to_fit(600, 600)
     img_orig.write(uploaded_image)
     size = "#{img_orig.columns}x#{img_orig.rows}"

     render :template => "logos/precrop_without_space",
            :layout => false,
            :locals => { :logo_crop_text => t('avatar.crop'),
                         :image_size => size }
   end

   if params[:upload_crop]
     images_path = File.join(Rails.root.to_s, "public", "images")
     tmp_path = File.join(images_path, "tmp")
     final_path = FileUtils.mkdir_p(tmp_path + "/#{params[:crop_size][:rand]}")
     uploaded_image = File.join(final_path, "uploaded_logo.png")

     img = Magick::Image.read(uploaded_image).first

     crop_args = [Integer(params[:crop_size][:x]),Integer(params[:crop_size][:y]),Integer(params[:crop_size][:width]),Integer(params[:crop_size][:height])]
     crop_img = img.crop(*crop_args)

     temp_file = File.open(uploaded_image, "w+")
     crop_img.write(temp_file.path)
     temp_file.close

     render :text => ""
     #render :text => "" + params[:crop_size][:x].to_s + "," + params[:crop_size][:y].to_s + "," + params[:crop_size][:height].to_s + "," + params[:crop_size][:width].to_s + "," + "<img src= '" +uploaded_image.to_s + "'>"
   end

  end

  def precrop

    if params['logo']['media'].blank?
      redirect_to request.referer
      return
    end
    @logo = space.logo || Logo.new

    temp_logo = TempLogo.new(Logo, space, params[:logo])
    TempLogo.to_session(session, temp_logo)

    render :template => "logos/precrop",
           :layout => false,
           :locals => {:logo_crop_text => t('logo.crop'),
                       :form_for => [space,@logo],
                       :form_url => space_logo_path(space),
                       :image => temp_logo.image
                      }
  end


  def create
    if params[:crop_size].present?
      temp_logo = TempLogo.from_session(session)
      params[:logo] = temp_logo.crop_and_resize params[:crop_size]
    end
    @logo = space.build_logo(params[:logo])
    if @logo.save
      flash[:success] = t('logo.created')
      redirect_to edit_space_path(space)
    else
      flash[:error] = t('error', :count => @logo.errors.size) + @logo.errors.to_xml
      redirect_to edit_space_path(space)
    end

  end

  def update
    if params[:crop_size].present?
      temp_logo = TempLogo.from_session(session)
      params[:logo] = temp_logo.crop_and_resize params[:crop_size]
    end
    @logo = space.logo
    if @logo.update_attributes(params[:logo])
      flash[:success] = t('logo.created')
      redirect_to edit_space_path(space)
    else
      flash[:error] = t('error', :count => @logo.errors.size) + @logo.errors.to_xml
      redirect_to edit_space_path(space)
    end
  end

  private

  def max_word_length text
    first_pos = 0
    max_length = 0
    while !((pos = (text+" ").index(' ', first_pos)).nil?)
      if (pos - first_pos) > max_length
        max_length = pos - first_pos
      end
      first_pos = pos + 1
    end
    return max_length
  end

  def count_potential_lines text
    return text.count(" ")
  end

  def multiline_point_size text, width, height
    size_based_on_width = 1.7 * width / max_word_length(text)
    size_based_on_lines = 0.6 * height / count_potential_lines(text)
    if size_based_on_width > size_based_on_lines
      return size_based_on_lines
    else
      return size_based_on_width
    end
  end

  def singleline_point_size text, width
    return 1.7 * width / text.length
  end

=begin
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
=end

  def create_auto_logo text, logo_style, event_logo

    # We establish the paths for the pre-defined images, and the temporal dir for the generated logo
    images_path = File.join(Rails.root.to_s, "public", "images")
    tmp_path = File.join(images_path, "tmp")
    final_path = FileUtils.mkdir_p(tmp_path + "/#{params[:rand_name]}")
    if event_logo
      background_generic = File.join(images_path, "vcc-event-logo-bg.png")
    else
      background_generic = File.join(images_path, "vcc-logo-bg.png")
    end
    #background_generated = File.join(tmp_path, "vcc-logo-#{params[:rand_name]}-#{logo_style}.png")
    background_generated = File.join(final_path, "vcc-logo-#{params[:rand_name]}-#{logo_style}.png")

    # We open, read-only, the generic background image
    f = File.open(background_generic, "r")
    img = Magick::Image.read(f).first

    # This will be the blank image which will contain the text
    logo_text = Magick::Image.new(img.columns, img.rows)
    # To create the text, we use a new "Draw" object, and set some basic styles
    gc = Magick::Draw.new
    gc.font_family = "Helvetica"
    gc.font_style = Magick::ObliqueStyle
    gc.font_weight = Magick::LighterWeight
    gc.gravity = Magick::CenterGravity
    gc.stroke = "darkblue"
    gc.stroke_opacity(1)
    gc.text_antialias(true)
    gc.stroke_antialias(true)
    gc.stroke_linecap("round")
    gc.fill = "darkblue"

    # Depending on the desired logo_style, we create a text or another
    case logo_style
      when 1
        gc.pointsize = 0.7 * (multiline_point_size text+"\\n", img.columns, img.rows)
        gc.gravity = Magick::SouthGravity
        gc.annotate(logo_text,img.columns,img.rows,0,0,text+"\\n")
        auto_logo = img.composite!(logo_text, Magick::CenterGravity, Magick::ColorBurnCompositeOp)
      when 2
        gc.pointsize = singleline_point_size text, img.columns
        gc.annotate(logo_text,img.columns,img.rows,0,0,text)
        logo_text = logo_text.shade(true, 300, 30)
        auto_logo = img.composite!(logo_text, Magick::CenterGravity, Magick::HardLightCompositeOp)
      when 3
        gc.pointsize = multiline_point_size text, img.columns, img.rows
        text = text.gsub(" ", "\\n")
        gc.annotate(logo_text,0,0,0,0,text)
        auto_logo = img.composite!(logo_text, Magick::CenterGravity, Magick::ColorBurnCompositeOp)
      when 4
        gc.pointsize = multiline_point_size text, img.columns, img.rows
        text = text.gsub(" ", "\\n")
        gc.annotate(logo_text,img.columns,img.rows,0,0,text)
        logo_text = logo_text.shade(false, 300, 30)
        blank_bg = Magick::Image.new(img.columns, img.rows, GradientFill.new(0, 0, img.columns, 0, '#EBEBEB', '#BDD8EB'))
        auto_logo = blank_bg.composite!(logo_text, Magick::CenterGravity, Magick::HardLightCompositeOp)
      when 5
        gc.pointsize = multiline_point_size text, img.columns, img.rows
        text = text.gsub(" ", "\\n")
        gc.annotate(logo_text,img.columns,img.rows,0,0,text)
        logo_text = logo_text.shade(true, 300, 25)
        #blank_bg = Magick::Image.new(img.columns, img.rows, GradientFill.new(0, 0, img.columns, 0, '#EBEBEB', '#BDD8EB'))
        auto_logo = img.composite!(logo_text, Magick::CenterGravity, Magick::HardLightCompositeOp)
    end
    f.close

    # Finally, we store the new image in the temp path
    auto_logo.write("png:" + background_generated)
  end
end
