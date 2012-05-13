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

# Require Station Model
#require_dependency "#{ Rails.root.to_s }/vendor/plugins/station/app/models/tag"

class Tag < ActiveRecord::Base
  def self.cloud(args = {})
    find(:all, :select => 'tags.* ,count(*) as popularity',
    :limit => args[:limit] || 30,
    :joins => "JOIN taggings ON taggings.tag_id = tags.id",
    :conditions => args[:conditions],
    :group => "taggings.tag_id",
    :order => "id")
  end

  #-#-# from station

  DELIMITER = "," # Controls how to split and join tagnames from strings. You may need to change the <tt>validates_format_of parameters</tt> if you change this.

  belongs_to :container, :polymorphic => true

  scope :popular, :order => "taggings_count DESC"

  # If database speed becomes an issue, you could remove these validations and rescue the ActiveRecord database constraint errors instead.
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [ :container_id, :container_type ]

  # Change this validation if you need more complex tag names.
  validates_format_of :name, :with => /^[\w\_\ \-]+$/, :message => "can not contain special characters"

  has_many :taggings, :dependent => :destroy

  for taggable in ActiveRecord::Taggable.symbols
    has_many taggable, :through => :taggings,
                       :source => :taggable,
                       :source_type => taggable.to_s.classify
  end

  # All the instances tagged with some Tag
  def taggables
    ActiveRecord::Taggable.symbols.map{ |t| send(t) }.flatten
  end


  # Callback to strip extra spaces from the tagname before saving it. If you allow tags to be renamed later, you might want to use the <tt>before_save</tt> callback instead.
  before_create :before_create_method
  def before_create_method
    self.name = name.strip.squeeze(" ")
  end

  def to_param
    name
  end

  # Em attribute for building the tag_cloud
  def em
    1 + ( taggings_count - 1 ) * 0.05
  end

end
