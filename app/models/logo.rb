# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2012 Mconf
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'RMagick'

class Logo < ActiveRecord::Base
  include Magick

  ASPECT_RATIO_S = "188/143"
  ASPECT_RATIO_F = 188.0/143.0

  has_attachment :max_size => 2.megabyte,
                 :storage => :file_system,
                 :content_type => :image,
                 :thumbnails => {
                    'w256' => '256x',
                    'h256' => 'x256',
                    'w128' => '128x',
                    'h128' => 'x128',
                    'w96' => '96x',
                    'h96' => 'x96',
                    'w72' => '72x',
                    'h72' => 'x72',
                    'w64' => '64x',
                    'h64' => 'x64',
                    'w48' => '48x',
                    'h48' => 'x48',
                    'w32' => '32x',
                    'h32' => 'x32',
                    'w22' => '22x',
                    'h22' => 'x22',
                    'w16' => '16x',
                    'h16' => 'x16',
                    'front' => '188x143!'
                 }

  validate :aspect_ratio

  def aspect_ratio
    unless temp_path.blank?
      img = Magick::Image.read(temp_path).first
      unless (img.columns.to_f/img.rows.to_f*10).round == (ASPECT_RATIO_F*10).round
        errors.add(:base, "Aspect ratio invalid. Enable javascript to crop the image easily." )
      end
    else
      errors.add(:base, "Temp path is blank." )
    end
  end

  #-#-# from station

  # has_attachment :max_size => 2.megabyte,
  #                :content_type => :image,
  #                :thumbnails => {
  #                  '256' => '256x256>',
  #                  '128' => '128x128>',
  #                  '96' => '96x96>',
  #                  '72' => '72x72>',
  #                  '64' => '64x64>',
  #                  '48' => '48x48>',
  #                  '32' => '32x32>',
  #                  '22' => '22x22>',
  #                  '16' => '16x16>'
  #                }

  alias_attribute :media, :uploaded_data

  belongs_to :db_file
  belongs_to :logoable, :polymorphic => true

  validates_as_attachment

  acts_as_resource :disposition => :inline

  # Returns the image path for this resource
  def logo_image_path(options = {})
    respond_to?(:public_filename) ?
      public_filename(options[:size]) :
      [ self, { :format => self.format, :thumbnail => options[:size] } ]
  end

end
