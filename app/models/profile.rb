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

require 'vpim/vcard'
require 'prism'

class Profile < ActiveRecord::Base
  attr_accessor :vcard
  
  belongs_to :user
  accepts_nested_attributes_for :user

  acts_as_taggable :container => false
  has_logo :class_name => "Avatar"
  
  # The order implies inclusion: everybody > members > public_fellows > private_fellows
  VISIBILITY = [:everybody, :members, :public_fellows, :private_fellows, :nobody]
  
  before_validation do |profile|
    if profile.url
      if (profile.url.index('http') != 0)
        profile.url = "http://" << profile.url 
      end
    end
  end

  before_validation :from_vcard

  validate :validate_method
  def validate_method
    errors.add_to_base(@vcard_errors) if @vcard_errors.present?
  end
  
  def prefix
    self.prefix_key.include?("title_formal.") ? I18n.t(self.prefix_key) : self.prefix_key
  end

  def from_vcard
    return unless @vcard.present?

    @vcard = Vpim::Vcard.decode(@vcard).first
    
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
    
    #FAX
    if !@vcard.telephone('fax').nil?
      self.fax = @vcard.telephone('fax') 
    end

   #NAME
   if !@vcard.name.nil?
     
      temporal = ''
      
      if !@vcard.name.prefix.eql? ''
        self.prefix_key = @vcard.name.prefix
      end  
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
      
    #EMAIL
    if !@vcard.email('pref').nil? 
      self.user.email = @vcard.email('pref')
    else 
      if !@vcard.email('work').nil?
        self.user.email = @vcard.email('work')
      elsif !@vcard.email('home').nil?
        self.user.email = @vcard.email('home')
      elsif !(@vcard.emails.nil?||@vcard.emails[0].nil?)
        self.user.email = @vcard.emails[0]
      end
    end
    
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
  rescue
    @vcard_errors = I18n.t("vCard.corrupt")
  end

  def from_hcard(uri)
    hcard = Prism.find(uri, :hcard)

    if hcard.blank?
      errors.add_to_base(I18n.t("hcard.not_found"))
      return
    end

    # FIXME: this should be DRYed with from_vcard

    if hcard.tel
      self.phone = hcard.tel
    end

    if hcard.n
      if hcard.n.honorific_prefix
        self.prefix_key = hcard.n.honorific_prefix
      end  

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
        vname.prefix = prefix
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

      if mobile.blank?
        maker.add_tel('Not defined') do |vtel|
          vtel.location = 'cell'
        end
      else
        maker.add_tel(mobile) do |vtel|
          vtel.location = 'cell'
        end  
      end

      if fax.blank?
        maker.add_tel('Not defined') do |vtel|
          vtel.location = 'work'
          vtel.capability = 'fax'
        end
      else
        maker.add_tel(fax) do |vtel|
          vtel.location = 'work'
          vtel.capability = 'fax'
        end
      end

      maker.add_email(user.email) { |e| e.location = 'work' }

      maker.add_url((url  || ""))
    end
  end


  authorizing do |agent, permission|
    if self.user == agent
      true
    elsif (permission == :read)
      case visibility
        when VISIBILITY.index(:everybody)
          true
        when VISIBILITY.index(:members)
          agent != Anonymous.current
        when VISIBILITY.index(:public_fellows)
          self.user.public_fellows.include?(agent)
        when VISIBILITY.index(:private_fellows)
          self.user.private_fellows.include?(agent)
        when VISIBILITY.index(:nobody)
          false
      end
    end
  end
end
