class Group < ActiveRecord::Base
 
    has_and_belongs_to_many :users
    belongs_to :space
    
    after_create { |group| 
    if group.reload_mail_list_server_because_of_environment
    group.request_update_at_jungla
      group.mail_list_archive
      `scp temp vcc@jungla.dit.upm.es:/users/jungla/vcc/listas/automaticas/vcc-#{ group.name}`
    end
    }
    
    after_destroy { |group|
    if group.reload_mail_list_server_because_of_environment
      group.request_update_at_jungla
      `ssh vcc@jungla.dit.upm.es rm /users/jungla/vcc/listas/automaticas/vcc-#{ group.name }`
    end
    }
    
    before_update { |group|
    if group.reload_mail_list_server_because_of_environment
      group.request_update_at_jungla
      `ssh vcc@jungla.dit.upm.es rm /users/jungla/vcc/listas/automaticas/vcc-#{ group.name }`
    end 
    }
    
    after_update { |group|
    if group.reload_mail_list_server_because_of_environment
      group.mail_list_archive
      `scp temp vcc@jungla.dit.upm.es:/users/jungla/vcc/listas/automaticas/vcc-#{ group.name}`
    end
    }
    
    
    # Do not reload mail list server if not in production mode, it could cause server overload
    def reload_mail_list_server_because_of_environment
      if RAILS_ENV == "production"
        true
      else
        false
      end
    end
    
    def request_update_at_jungla
      `ssh vcc@jungla.dit.upm.es touch /users/jungla/vcc/listas/automaticas/vcc-ACTUALIZAR`
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
       File.open("temp", 'w') {|f| f.write(doc) }
     end
   
   def self.atom_parser(data)
    
    e = Atom::Entry.parse(data)
    debugger
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
  
end
