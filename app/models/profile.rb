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

  def validate
    errors.add_to_base(@vcard_errors) if @vcard_errors.present?
  end

  def from_vcard
    return unless @vcard.present?

    @vcard = Vpim::Vcard.decode(@vcard).first
    
    #TELEFONO: Primero el preferente, sino, trabajo, sino, casa, 
    #y sino, cualquier otro numero
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
    
    #FAX: Si existe bien, sino no se altera
    if !@vcard.telephone('fax').nil?
      self.fax = @vcard.telephone('fax') 
    end

   #NOMBRE: Guardamos el prefijo si existe en su campo
   #y con el resto formamos el nombre de la forma
   # "given" + "additional" + "family"
   if !@vcard.name.nil?
     
      temporal = ''
      
      if !@vcard.name.prefix.eql? ''
        self.prefix = @vcard.name.prefix
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
        self.user.login = temporal.unpack('M*')[0];
      end
   end
      
    #EMAIL: Primero el preferente, sino, trabajo, sino, casa, 
    #y sino, cualquier otro mail
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
    
    #URL: Primero el preferente, sino, trabajo, sino, casa, 
    #y sino, cualquier otro mail
    if !@vcard.url.nil?
        self.url = @vcard.url.uri.to_s
    end

    #DESCRIPCIÓN: Si existe Note, se pone en descripción
    if !@vcard.note.nil?
        self.description = @vcard.note.unpack('M*')[0]
    end
  
    #ORGANIZACIÓN: Por ahora solo se tiene en cuenta
    #el nombre de la organización. Hay campos para 
    #departamentos ... ¿útiles?
    if !@vcard.org.nil?  
      self.organization = @vcard.org[0].unpack('M*')[0]
    end 
  
    #DIRECCIÓN: Buscamos preferente, sino trabajo, sino
    #cualquier otra dirección. Solo ejecutamos los cambios
    #si hay una address en la vcard
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
    if !address.nil? #Si ha habido algún resultado, lo guardamos
          self.address = address.street.unpack('M*')[0] + ' ' + address.extended.unpack('M*')[0]
          self.city = address.locality.unpack('M*')[0]
          self.zipcode = address.postalcode.unpack('M*')[0]
          self.province = address.region.unpack('M*')[0]
          self.country = address.country.unpack('M*')[0]
    end
  rescue
    @vcard_errors = I18n.t("vCard.corrupt")
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
        vaddr.street = address
        vaddr.locality = city
        vaddr.country = country
        vaddr.postalcode = zipcode
        vaddr.region = province
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

      maker.add_url(url)
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
