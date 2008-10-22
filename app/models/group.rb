class Group < ActiveRecord::Base
 
    has_and_belongs_to_many :users
    belongs_to :space
    
    after_create { |group| 
    if RAILS_ENV == "production"
    group.request_update_at_jungla
    `ssh ebarra@jungla.dit.upm.es touch /users/jungla/ebarra/listas/automaticas/vcc-#{ group.name}.txt`
    `ssh ebarra@jungla.dit.upm.es "echo #{ group.mail_list} >> /users/jungla/ebarra/listas/automaticas/vcc-#{ group.name}.txt"`
    end
    }
    
    after_destroy { |group|
    if RAILS_ENV == "production"
      group.request_update_at_jungla
    `ssh ebarra@jungla.dit.upm.es rm /users/jungla/ebarra/listas/automaticas/vcc-#{ group.name }.txt`
    end
    }
    
    after_update { |group|
    if RAILS_ENV == "production"
      group.request_update_at_jungla
      `ssh ebarra@jungla.dit.upm.es rm /users/jungla/ebarra/listas/automaticas/vcc-#{ @old_name }.txt`
      `ssh ebarra@jungla.dit.upm.es touch /users/jungla/ebarra/listas/automaticas/vcc-#{ group.name}.txt`
      `ssh ebarra@jungla.dit.upm.es "echo #{ group.mail_list} >> /users/jungla/ebarra/listas/automaticas/vcc-#{ group.name}.txt"`
    end
    }
    
    
    def request_update_at_jungla
      `ssh ebarra@jungla.dit.upm.es touch /users/jungla/ebarra/listas/automaticas/vcc-ACTUALIZAR`
    end
    
    def mail_list
       str =""
       self.users.each do |person|
       str << "#{person.login}  <#{person.email}> \n"
       end
       str
    end
  
end
