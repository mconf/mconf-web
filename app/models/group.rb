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

class Group < ActiveRecord::Base

  #MAIL_DIR = "/var/local/global2"

  has_many :memberships, :dependent => :destroy
  has_many :users, :through => :memberships
  belongs_to :space

  validates_presence_of :name
  validates_uniqueness_of(:mailing_list, :allow_nil => true, :allow_blank => true, :message => I18n.t('group.existing'))

  def validate

    reserved_mailing_list = 'sir'

    for user in users
      unless user.stages.include?(space)
        errors.add(:users, I18n.t('space.group_not_belong'))
      end
    end

    if self.mailing_list && self.mailing_list.present?

      self.mailing_list = self.mailing_list.downcase

      if self.mailing_list == reserved_mailing_list
        errors.add(I18n.t('mailing_list.reserved', :systemMailingList => "vcc-#{reserved_mailing_list}"))
      end

      if self.mailing_list.match(/^[a-z0-9][\w\-\.]*$/).to_s == ""
        errors.add(I18n.t('mailing_list.invalid'))
      end

    end

  end

  before_save { |group|
    if group.mailing_list.present?
      group.mailing_list = group.mailing_list.gsub(/ /, "-")
      group.regenerate_lists
    else
      group.mailing_list = remove_accents(group.name)
      group.regenerate_lists
    end
  }

  after_create { |group|
    #create the new mailing_list if it has the option activated
    if group.mailing_list.present?
      group.regenerate_lists
    end
  }

  after_destroy { |group|
    if group.mailing_list
      #destroy the existing mailing_list
      delete_list(group, group.mailing_list)
      request_list_update
    end
  }

  after_update { |group|

    #delete the old mailing_list
    if group.mailing_list_changed?
      delete_list(group,group.mailing_list_was) if group.mailing_list_was.present?
    else
      delete_list(group,group.mailing_list) if group.mailing_list.present?
    end

    #create the new mailing_list
    if group.mailing_list.present?
      group.regenerate_lists
    end
    request_list_update
  }

  # Do not reload mail list server if not in production mode, it could cause server overload
  #def self.reload_mail_list_server_because_of_environment
  #RAILS_ENV == "production"
  #end

  def self.request_list_update
    #`/usr/local/bin/newautomatic.sh`
  end

  def self.delete_list(group,list)
=begin
    if !list.include?("-DISABLED-")
      `rm -f #{MAIL_DIR}/automatic_lists/vcc-#{list}`
      `rm -f #{MAIL_DIR}/automatic_ro_lists/vcc-ro-#{list}`
    end
=end
  end

  def self.disable_list(group)
    Group.delete_list(group,group.mailing_list)
    group.update_attribute :mailing_list, "#{group.mailing_list.split("-RESTORED").first}-DISABLED-#{Time.now.to_i}"
  end

  def self.enable_list(group)
    group.update_attribute :mailing_list, "#{group.mailing_list.split("-DISABLED-").first}-RESTORED"
  end




  def email_group_name
    self.name.gsub(/ /, "_")
  end

  def self.atom_parser(data)

    e = Atom::Entry.parse(data)


    group = {}
    group[:name] = e.title.to_s

    group[:user_ids] = []

    e.get_elems(e.to_xml, "http://sir.dit.upm.es/schema", "entryLink").each do |times|

      user = User.find_by_login(times.attribute('login').to_s)
      group[:user_ids] << user.id
    end

    resultado = {}

    resultado[:group] = group

    return resultado
  end


  def self.remove_accents(str)
    accents = {
      ['á','à','â','ä','ã'] => 'a',
      ['Ã','Ä','Â','À'] => 'A',
      ['é','è','ê','ë'] => 'e',
      ['Ë','É','È','Ê'] => 'E',
      ['í','ì','î','ï'] => 'i',
      ['Î','Ì'] => 'I',
      ['ó','ò','ô','ö','õ'] => 'o',
      ['Õ','Ö','Ô','Ò','Ó'] => 'O',
      ['ú','ù','û','ü'] => 'u',
      ['Ú','Û','Ù','Ü'] => 'U',
      ['ç'] => 'c', ['Ç'] => 'C',
      ['ñ'] => 'n', ['Ñ'] => 'N'
    }
    accents.each do |ac,rep|
      ac.each do |s|
        str = str.gsub(s, rep)
      end
    end
    str = str.gsub(/[^a-zA-Z0-9 ]/,"")
    str = str.gsub(/[ ]+/," ")
    str = str.gsub(/ /,"-")
    str = str.downcase
  end

  # Transforms the list of users in the group into a string for the mail list server
  def generate_mail_list(type)
    str =""
    self.users.each do |person|
      if (self.space.role_for?(person, :name => "Admin") or self.space.role_for?(person, :name => "User")) and type.eql? "main"
        str << "#{Group.remove_accents(person.login)}  <#{person.email}> \n" #Main List
      elsif self.space.role_for?(person, :name => "Invited") and type.eql? "invited"
        str << "#{Group.remove_accents(person.login)}  <#{person.email}> \n" #Invited List
      end
    end
    if (type.eql? "main")
      str << "vcc-ro-#{self.mailing_list}@#{Site.find(:first).domain} \n"
    end
    str
  end

  def regenerate_lists
    if !self.space.nil?
      #puts self.mailing_list
      main = "#{self.generate_mail_list("main")}"
      #puts "Main: " + self.generate_mail_list("main")
      invited = "#{self.generate_mail_list("invited")}"
      #puts "Invited: " + self.generate_mail_list("invited")

      if self.mailing_list
=begin
        FileUtils.mkdir_p("#{MAIL_DIR}/automatic_lists/")
        FileUtils.mkdir_p("#{MAIL_DIR}/automatic_ro_lists/")

        if !self.mailing_list.include?("-DISABLED-")
          File.new("#{MAIL_DIR}/automatic_lists/vcc-#{self.mailing_list}", 'w')
          File.new("#{MAIL_DIR}/automatic_ro_lists/vcc-ro-#{self.mailing_list}", 'w')

          File.open("#{MAIL_DIR}/automatic_lists/vcc-#{self.mailing_list}", 'w') {|f| f.write(main) }
          File.open("#{MAIL_DIR}/automatic_ro_lists/vcc-ro-#{self.mailing_list}", 'w') {|f| f.write(invited) }
        end
=end
        #`/usr/local/bin/newautomatic.sh`
      end
    end
  end

end
