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
        errors.add("", "The mailing list vcc-sir@dit.upm.es is reserved")
      end
      
      if self.mailing_list && self.mailing_list.match("[^a-z0-9\s]")
        errors.add("", "The mailing list have invalid characters. Only lowercase letters and numbers are allowed")
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
        `ssh vcc@jungla.dit.upm.es touch /users/jungla/vcc/listas/automaticas/vcc-ACTUALIZAR`
      end
    end
    
    def self.copy_at_jungla(group,list)
      if check_domain
        `scp #{ group.temp_file } vcc@jungla.dit.upm.es:/users/jungla/vcc/listas/automaticas/vcc-#{list}`
      end
    end
    
    def self.delete_at_jungla(group,list)
      if check_domain
        `ssh vcc@jungla.dit.upm.es rm /users/jungla/vcc/listas/automaticas/vcc-#{list}`
      end
    end
    
    # Transforms the list of users in the group into a string for the mail list server
    def mail_list
       str =""
       self.users.each do |person|
       str << "#{person.login}  <#{person.email}> \n"
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

end
