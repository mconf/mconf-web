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
 
    has_many :memberships, :dependent => :destroy
    has_many :users, :through => :memberships
    belongs_to :space
    
    validates_presence_of :name
    validates_uniqueness_of(:mailing_list, :allow_nil => true, :allow_blank => true,:message => "name has already been taken")
    
    def validate
      for user in users
        unless user.stages.include?(space)
          errors.add(:users, "not belongs to the space of the group")
        end
      end
      
      if self.mailing_list == "sir"
        errors.add("The mailing list vcc-sir@dit.upm.es is reserved")
      end
      
      if self.mailing_list && self.mailing_list.match(/^[a-zA-Z1-9][\s\w\-\.]*$/).to_s != self.mailing_list
        errors.add("The mailing list have invalid characters. Only lowercase letters and numbers are allowed")
      end
      
    end
    
    before_save { |group|
      if group.mailing_list.present?
        group.mailing_list = group.mailing_list.gsub(/ /, "-")
      end
    }
    
    after_create { |group|
        #create the new mailing_list if it has the option activated
        if group.mailing_list.present?
          group.mail_list_archive
          copy_at_jungla(group, group.mailing_list)
          request_update_at_jungla
        end
    }
    
    after_destroy { |group|
        if group.mailing_list
          #destroy the existing mailing_list
          delete_at_jungla(group, group.mailing_list)
          request_update_at_jungla
        end
    }   
    
    after_update { |group|
    
        #delete the old mailing_list      
        if group.mailing_list_changed?
          delete_at_jungla(group,group.mailing_list_was) if group.mailing_list_was.present?
        else
          delete_at_jungla(group,group.mailing_list) if group.mailing_list.present?
        end
  
        #create the new mailing_list
        if group.mailing_list.present?  
          group.mail_list_archive        
          copy_at_jungla(group,group.mailing_list)
        end
        request_update_at_jungla
    }
       
    # Do not reload mail list server if not in production mode, it could cause server overload
    #def self.reload_mail_list_server_because_of_environment
      #RAILS_ENV == "production"
    #end
    
    def self.check_domain
      Site.current.domain == "vcc.dit.upm.es"
    end
    
    def self.request_update_at_jungla
      if check_domain
        `sudo -u vcc-list ssh vcc@jungla.dit.upm.es touch /users/jungla/vcc/listas/automaticas/vcc-ACTUALIZAR`
      end
    end
    
    def self.copy_at_jungla(group,list)
      if check_domain
        `sudo -u vcc-list scp #{ group.temp_file } vcc@jungla.dit.upm.es:/users/jungla/vcc/listas/automaticas/vcc-#{list}`
      end
    end
    
    def self.delete_at_jungla(group,list)
      if check_domain
        `sudo -u vcc-list ssh vcc@jungla.dit.upm.es rm /users/jungla/vcc/listas/automaticas/vcc-#{list}`
      end
    end
    
    # Transforms the list of users in the group into a string for the mail list server
    def mail_list
       str =""
       self.users.each do |person|
         str << "#{Group.remove_accents(person.login)}  <#{person.email}> \n"
       end
       str
   end
   
   def mail_list_archive
     doc = "#{self.mail_list}"
     File.open(temp_file, 'w') {|f| f.write(doc) }
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


  def temp_file
     @temp_file ||= "/tmp/sir-grupostemp-#{ rand }"
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
    #str = str.downcase
  end


end
