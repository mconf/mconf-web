# -*- coding: utf-8 -*-
# This file is part of Mconf-Web, a web application that provides access
# to the Mconf webconferencing system. Copyright (C) 2010-2015 Mconf.
#
# This file is licensed under the Affero General Public License version
# 3 or later. See the LICENSE file.

require 'vpim/vcard'
require 'prism'

class Profile < ActiveRecord::Base
  attr_accessor :vcard

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :crop_img_w, :crop_img_h
  mount_uploader :logo_image, LogoImageUploader

  after_create :crop_avatar
  after_update :crop_avatar

  def crop_avatar
    logo_image.recreate_versions! if crop_x.present?
  end

  after_update :update_webconf_room

  def update_webconf_room
    if self.full_name_changed?
      if self.full_name_was == self.user.bigbluebutton_room.name
        params = {
          :name => self.full_name
        }
        self.user.bigbluebutton_room.update_attributes(params)
      end
    end
  end

  belongs_to :user

  # The order implies inclusion: everybody > members > public_fellows > private_fellows
  VISIBILITY = [:everybody, :members, :public_fellows, :private_fellows, :nobody]

  validates :full_name, presence: true

  before_validation :correct_url
  def correct_url
    if url.present?
      if (url.index('http://') != 0)
        self.url = "http://" << url
      end
    end
  end

  after_validation :sanitize_encodings
  def sanitize_encodings
    fields = [
      :organization, :phone, :address, :city, :zipcode, :province, :country,
      :description, :url, :full_name
    ]

    if vcard.present?
      fields.each do |field|
        self.send("#{field}=".to_sym, self.send(field).force_encoding('utf-8')) if self.send("#{field}_changed?")
      end
    end
  end

  # Returns the user's first name(s) making sure it is at least `min_length` characters
  # long. Might return a string with more than a word.
  def first_names(min_length = 5)
    unless self.full_name.blank?
      # parse_name(self.full_name)[:first_name]
      names = self.full_name.split(' ')
      names.inject('') do |memo, name|
        if memo.blank?
          name
        elsif memo.length < min_length
          "#{memo} #{name}"
        else
          memo
        end
      end
    end
  end

  before_validation :from_vcard
  def from_vcard
    return if @vcard.nil?

    @vcard = Vpim::Vcard.decode(@vcard).first

    # This is here because sometimes the lib
    # will return nil instead of throwing an exception
    if @vcard.blank?
      raise Vpim::UnsupportedError
    end

    #TELEPHONE
    if !@vcard.telephone('pref').nil?
      self.phone = @vcard.telephone('pref')
    else
      if !@vcard.telephone('work').nil?
        self.phone = @vcard.telephone('work')
      elsif !@vcard.telephone('home').nil?
        self.phone = @vcard.telephone('home')
      elsif !(@vcard.telephones.nil?||@vcard.telephones[0].nil?)
        self.phone = @vcard.telephones[0]
      end
    end

    #NAME
    if !@vcard.name.nil?
      temporal = ''

      if !@vcard.name.given.eql? ''
        temporal =  @vcard.name.given + ' '
      end
      if !@vcard.name.additional.eql? ''
        temporal = temporal + @vcard.name.additional + ' '
      end
      if !@vcard.name.family.eql? ''
        temporal = temporal + @vcard.name.family
      end

      if !temporal.eql? ''
        self.full_name = temporal.unpack('M*')[0];
      end
   end

    # For now, email can't be edited from profile
    #EMAIL
    # if !@vcard.email('pref').nil?
    #   self.user.email = @vcard.email('pref')
    # else
    #   if !@vcard.email('work').nil?
    #     self.user.email = @vcard.email('work')
    #   elsif !@vcard.email('home').nil?
    #     self.user.email = @vcard.email('home')
    #   elsif !(@vcard.emails.nil?||@vcard.emails[0].nil?)
    #     self.user.email = @vcard.emails[0]
    #   end
    # end

    #URL
    if !@vcard.url.nil?
      self.url = @vcard.url.uri.to_s
    end

    #DESCRIPTION
    if !@vcard.note.nil?
      self.description = @vcard.note.unpack('M*')[0]
    end

    #ORGANIZATION
    if !@vcard.org.nil?
      self.organization = @vcard.org[0].unpack('M*')[0]
    end

    #DIRECTION
    address = nil;
    if !@vcard.address('pref').nil?
      address = @vcard.address('pref')
    else
      if !@vcard.address('work').nil?
        address = @vcard.address('work')
      elsif !(@vcard.addresses.nil?||@vcard.addresses[0].nil?)
        address = @vcard.addresses[0]
      end
    end
    if !address.nil?
          self.address = address.street.unpack('M*')[0] + ' ' + address.extended.unpack('M*')[0]
          self.city = address.locality.unpack('M*')[0]
          self.zipcode = address.postalcode.unpack('M*')[0]
          self.province = address.region.unpack('M*')[0]
          self.country = address.country.unpack('M*')[0]
    end
  rescue Vpim::InvalidEncodingError, Vpim::UnsupportedError, RuntimeError => e
    raise e if e.class == RuntimeError && e.message != 'Not a valid vCard'
    self.errors.add(:vcard, I18n.t("vCard.corrupt"))
  end

  def from_hcard(uri)
    hcard = Prism.find(uri, :hcard)

    if hcard.blank?
      errors.add(:base, I18n.t("hcard.not_found"))
      return
    end

    # FIXME: this should be DRYed with from_vcard

    if hcard.tel
      self.phone = hcard.tel
    end

    if hcard.n
      full_name = hcard.fn ||
                  "#{ hcard.n.try(:given_name) } #{ hcard.n.try(:additional_name) } #{ hcard.n.try(:family_name) }".strip

      if full_name.present?
        self.full_name = full_name
      end
    end

    if hcard.email
      user.email = hcard.email
    end

    if hcard.url
        self.url = Array(hcard.url).first
    end

    if hcard.org
      self.organization = hcard.org
    end

    if hcard.adr
      if hcard.adr.street_address || hcard.adr.extended_address
        self.address = "#{ hcard.adr.street_address } #{ hcard.adr.extended_address }".strip
      end

      if hcard.adr.locality
        self.city = hcard.adr.locality
      end

      if hcard.adr.postal_code
        self.zipcode = hcard.adr.postal_code
      end

      if hcard.adr.region
        self.province = hcard.adr.region
      end
      if hcard.adr.country_name
        self.country = hcard.adr.country_name
      end
    end
  end

  #this method is used to compose the vcard file (.vcf) with the profile of an user
  def to_vcard
    Vpim::Vcard::Maker.make2 do |maker|
      maker.add_name do |vname|
        vname.given = user.name
      end

      maker.add_addr do |vaddr|
        vaddr.preferred = true
        vaddr.location = 'home'
        vaddr.street = (address || "")
        vaddr.locality = (city || "")
        vaddr.country = (country || "")
        vaddr.postalcode = (zipcode || "")
        vaddr.region = (province || "")
      end

      if phone.present?
        maker.add_tel(phone) do |vtel|
          vtel.location = 'work'
          vtel.preferred = true
        end
      end

      maker.add_email(user.email) { |e| e.location = 'work' }

      maker.add_url((url  || ""))
    end
  end

  def small_logo_image?
    logo_image.height < 100 || logo_image.width < 100
  end
end
