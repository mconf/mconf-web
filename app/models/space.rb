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

class Space < ActiveRecord::Base

  TMP_PATH = File.join(PathHelpers.images_full_path, "tmp")

  has_many :posts,  :dependent => :destroy
  has_many :events, :dependent => :destroy
  has_many :news, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
  has_many :tags, :dependent => :destroy, :as => :container
  has_logo
  has_one :bigbluebutton_room, :as => :owner, :dependent => :destroy
  extend FriendlyId
  friendly_id :name, :use => :slugged, :slug_column => :permalink

  accepts_nested_attributes_for :bigbluebutton_room

  validates :description, :presence => true

  # BigbluebuttonRoom requires an identifier with 3 chars generated from :name
  # So we'll require :name and :permalink to have length >= 3
  validates :name, :presence => true, :uniqueness => true, :length => { :minimum => 3 }
  validates :permalink, :presence => true, :length => { :minimum => 3 }

  acts_as_resource :param => :permalink
  acts_as_container :contents => [ :news, :posts, :attachments, :events ]
  acts_as_stage

  attr_accessor :invitation_ids
  attr_accessor :invitation_mails
  attr_accessor :invite_msg
  attr_accessor :inviter_id
  attr_accessor :invitations_role_id
  attr_accessor :default_logo
  attr_accessor :text_logo
  attr_accessor :rand_value
  attr_accessor :logo_rand

  default_scope :conditions => { :disabled => false }

  before_validation :update_logo
  after_validation :logo_mi
  after_validation :check_permalink
  after_update :update_webconf_room

  # Update the webconf room after updating the space
  def update_webconf_room
    if self.bigbluebutton_room
      bigbluebutton_room.update_attributes(:param => self.permalink, :name => self.name)
    end
  end

  # Returns the next 'count' events (starting in the current date) in this space.
  def upcoming_events(count)
    self.events.upcoming.first(5)
  end

  # Returns all admins of this space.
  def admins
    self.actors(:role => 'Admin')
  end

  # Return the number of unique pageviews for this space using the Statistic model.
  # Will throw an exception if the data in Statistic in incorrect.
  def unique_pageviews
    # Use only the canonical aggregated url of the space (all views have been previously added here in the rake task)
    corresponding_statistics = Statistic.where('url LIKE ?', '/spaces/' + self.permalink)
    if corresponding_statistics.size == 0
      return 0
    elsif corresponding_statistics.size == 1
      return corresponding_statistics.first.unique_pageviews
    elsif corresponding_statistics.size > 1
      raise "Incorrectly parsed statistics"
    end
  end

  #-#-#

  after_save do |space|
    if space.invitation_mails
      mails_to_invite = space.invitation_mails.split(/[\r,]/).map(&:strip)
      mails_to_invite.map { |email|
        params =  {:role_id => space.invitations_role_id.to_s, :email => email, :comment => space.invite_msg}
        i = space.invitations.build params
        i.introducer = User.find(space.inviter_id)
        i
      }.each(&:save)
    end
    if space.invitation_ids
      space.invitation_ids.map { |user_id|
        user = User.find(user_id)
        params = {:role_id => space.invitations_role_id.to_s, :email => user.email, :comment => space.invite_msg}
        i = space.invitations.build params
        i.introducer = User.find(space.inviter_id)
        i
      }.each(&:save)
    end
=begin
    if space.group_invitation_mails
      space.group_invitation_mails.each { |mail|
        Informer.deliver_space_group_invitation(space,mail)
      }
    end
=end
  end


  def resize path, size

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


  def update_logo
    return unless @default_logo.present?
    img_orig = Magick::Image.read(File.join(PathHelpers.images_full_path, @default_logo)).first
    img_orig = img_orig.scale(337, 256)
    images_path = PathHelpers.images_full_path
    final_path = FileUtils.mkdir_p(File.join(images_path, "tmp/#{@rand_value}"))
    img_orig.write(File.join(images_path, "tmp/#{@rand_value}/temp.jpg"))
    original = File.open(File.join(images_path, "tmp/#{@rand_value}/temp.jpg"))

    original_tmp = Tempfile.new("default_logo", "#{Rails.root.to_s}/tmp/")
    original_tmp_io = open(original_tmp)
    original_tmp_io.write(original.read)
    filename = File.join(images_path, @default_logo)
    (class << original_tmp_io; self; end;).class_eval do
      define_method(:original_filename) { filename.split('/').last }
      define_method(:content_type) { 'image/jpeg' }
      define_method(:size) { File.size(filename) }
    end

    logo = { :media => original_tmp_io }
    logo = self.build_logo(logo)

    images_path = PathHelpers.images_full_path
    tmp_path = File.join(images_path, "tmp")

    if @rand_value != nil
      final_path = FileUtils.rm_rf(tmp_path + "/#{@rand_value}")
    end

  end

  def logo_mi
    return unless @default_logo.present?
  end


  scope :public, lambda {
    where(:public => true)
  }


  def self.find_with_disabled *args
    self.with_exclusive_scope { find(*args) }
  end

  def self.find_with_disabled_and_param *args
    self.with_exclusive_scope { find_with_param(*args) }
  end

  def emailize_name
    self.name.gsub(" ", "")
  end

  # Users that belong to this space
  #
  # Options:
  # role:: Name of the role actors play in this space
  def users(options = {})
    actors(options)
  end

  def disable
    self.update_attributes(:disabled => true, :name => "#{name.split(" RESTORED").first} DISABLED #{Time.now.to_i}")
  end

  def enable
    self.update_attributes(:disabled => false, :name => "#{name.split(" DISABLED").first} RESTORED")
  end

  def is_last_admin?(user)
    admins = self.actors(:role => 'Admin')
    if admins.length != 1 then
      false
    elsif admins.include?(user)
      true
    else
      false
    end
  end

  def pending_join_requests_for?(user)
    jrs = self.admissions.find(:all, :conditions => {:type => "JoinRequest", :candidate_type => user.class.to_s, :candidate_id => user.id})
    jrs.each do |jr|
      if !(jr.processed?)
        return true
      end
    end
    return false
  end

  # Add a `user` to this space with the role `role_name` (e.g. 'User', 'Admin').
  def add_member!(user, role_name)
    role = Role.find_by_name_and_stage_type('Admin', 'Space')
    Permission.create! :user => user, :subject => self, :role => role
  end

  private

  # Checks whether there an error in :permalink or :bigbluebutton_room.param.
  # If there is, set the error in :name to be shown in the views.
  def check_permalink
    if self.errors[:permalink].size > 0
      self.errors.add :name, I18n.t('activerecord.errors.messages.invalid_identifier', :id => self.permalink)
    elsif self.bigbluebutton_room and self.bigbluebutton_room.errors[:param].size > 0
      self.errors.add :name, I18n.t('activerecord.errors.messages.invalid_identifier', :id => self.bigbluebutton_room.param)
    end

  end

end
