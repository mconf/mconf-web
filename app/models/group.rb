class Group < ActiveRecord::Base
 
    has_and_belongs_to_many :users
    belongs_to :space
    
    def mail_list
       str =""
       self.users.each do |person|
       str << "#{person.login}  <#{person.email}> \n"
       end
       str
    end
  
end
