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

  TMP_PATH = File.join(Rails.root.to_s, "public", "images", "tmp")

  has_many :posts,  :dependent => :destroy
  has_many :events, :dependent => :destroy
  #has_many :groups, :dependent => :destroy
  has_many :news, :dependent => :destroy
  has_many :attachments, :dependent => :destroy
#  has_many :agendas, :through => :events
  has_many :tags, :dependent => :destroy, :as => :container

  has_one :bigbluebutton_room, :as => :owner, :dependent => :destroy
  after_update :update_bbb_room
  after_create :create_bbb_room

  has_permalink :name, :permalink, :update => true

  acts_as_resource :param => :permalink
  acts_as_container :contents => [ :news, :posts, :attachments, :events ],
                    :sources => true
  acts_as_stage
  #attr_accessor :mailing_list_for_group
  attr_accessor :invitation_ids
  attr_accessor :invitation_mails
  #attr_accessor :group_invitation_mails
  attr_accessor :invite_msg
  attr_accessor :inviter_id
  #attr_accessor :group_inv_sender_id
  #attr_accessor :group_invitation_msg
  attr_accessor :invitations_role_id
  attr_accessor :default_logo
  attr_accessor :text_logo
  attr_accessor :rand_value
  attr_accessor :logo_rand

  attr_accessor :_attendee_password
  attr_accessor :_moderator_password

  # user.login and space.permalink should be unique
  validate :validate_unique_permalink_against_spaces

  # method adapted from PermalinkFu.create_unique_permalink
  def validate_unique_permalink_against_spaces

    # there's some user with a login == self.permalink
    if User.where(:login => self.permalink).count > 0
      if self.new_record?
        update_unique_permalink
      else
        self.errors.add :permalink, I18n.t('activerecord.errors.messages.taken')
      end
    end

  end

  def create_bbb_room
    create_bigbluebutton_room(:owner => self,
                              :server => BigbluebuttonServer.first,
                              :param => self.permalink,
                              :name => self.permalink,
                              :private => !self.public,
                              :moderator_password => self._moderator_password || SecureRandom.hex(4),
                              :attendee_password => self._attendee_password || SecureRandom.hex(4),
                              :logout_url => "/feedback/webconf/")
  end

  def update_bbb_room
    bigbluebutton_room.update_attributes(:param => self.permalink,
                                         :name => self.permalink,
                                         :private => !self.public)
  end

  def update_unique_permalink
    counter = 1
    limit, base = create_common_permalink
    return if limit.nil? # nil if the permalink has not changed or :if/:unless fail

    # check for duplication either on spaces permalinks or users logins
    while Space.where(:permalink => self.permalink).select{ |s| s.id != self.id }.count > 0 or
          User.where(:login => self.permalink).count > 0

      # try a new value
      suffix = "-#{counter += 1}"
      new_value = "#{base[0..limit-suffix.size-1]}#{suffix}"
      send("#{self.class.permalink_field}=", new_value)
    end
  end

  accepts_nested_attributes_for :bigbluebutton_room

  has_logo

  after_validation :logo_mi

  before_validation :update_logo

  # TODO is_indexed comes from Ultrasphinx
  #is_indexed :fields => ['name','description'],
  #           :conditions => "disabled = 0"

  validates_presence_of :name, :description
  validates_uniqueness_of :name

  #after_create { |space|
      #group = Group.new(:name => space.emailize_name, :space_id => space.id, :mailing_list => space.mailing_list)
      #group.users << space.users(:role => "admin")
      #group.users << space.users(:role => "user")
      #group.save
  #}


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
    img_orig = Magick::Image.read(File.join("public/images/", @default_logo)).first
    img_orig = img_orig.scale(337, 256)
    images_path = File.join(Rails.root.to_s, "public", "images")
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

    images_path = File.join(Rails.root.to_s, "public", "images")
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

  default_scope :conditions => {:disabled => false}

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

  def user_count
    users.size
  end

  # AtomPub
  def self.atom_parser(data)
    e = Atom::Entry.parse(data)

    space = {}
    space[:name] = e.title.to_s
    space[:description] = e.summary.to_s
    space[:deleted] = e.get_elem(e.to_xml, "http://schemas.google.com/g/2005", "deleted").text
    space[:parent_id] = e.get_elem(e.to_xml, "http://sir.dit.upm.es/schema", "parent_id").text

    visibility = e.get_elem(e.to_xml, "http://schemas.google.com/g/2005", "visibility").text
    space[:public] = visibility == "public"

    { :space => space }
  end

  def disable
    self.update_attributes(:disabled => true, :name => "#{name.split(" RESTORED").first} DISABLED #{Time.now.to_i}")
=begin
    for group in self.groups
      Group.disable_list(group)
    end
=end
  end

  def enable
    self.update_attributes(:disabled => false, :name => "#{name.split(" DISABLED").first} RESTORED")
=begin
    for group in self.groups
      Group.enable_list(group)
    end
=end
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

#  def videos
#
#    @space_videos = []
#
#    agendas.each do |agenda|
#      agenda.agenda_entries.select{|ae| ae.past? & ae.recording?}.each do |video|
#        @space_videos << video
#      end
#    end
#
#    @space_videos
#
#  end

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

  # There are previous authorization rules because of the stage
  # See acts_as_stage documentation
  authorizing do |agent, permission|
    if self.public? && [ :read, [ :read, :content ], [ :read, :performance ] ].include?(permission)
      true
    end
  end
end
