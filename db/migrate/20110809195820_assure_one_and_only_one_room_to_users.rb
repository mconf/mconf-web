class AssureOneAndOnlyOneRoomToUsers < ActiveRecord::Migration
  def self.up
    counter = 1
    #Remove all users rooms
    puts "===== Deleting all the rooms"
    BigbluebuttonRoom.destroy_all()
    
    #Create the user room
    puts "===== Creating users rooms"
    User.all.each do |u|

      base = u.profile.full_name
      while BigbluebuttonRoom.where(:name => base).count > 0

        #Rails.logger.info "Creating a new permalink for the space " + space.name                                                                                                 

        suffix = " #{counter += 1}"
        base = "#{base}#{suffix}"
        #space.update_attribute(:permalink,new_value)
        #Rails.logger.info "* Trying " + space.permalink                                                                                                                          
      end
      
      name = base

      BigbluebuttonRoom.create!(:owner => u,
                                :server => BigbluebuttonServer.first,
                                :param => u.login,
                                :name => name)
                                
    end
    
    #Create the space rooms
    puts "===== Creating space rooms"
    Space.all.each do |s|

      base = s.name
      while BigbluebuttonRoom.where(:name => base).count > 0

        #Rails.logger.info "Creating a new permalink for the space " + space.name                                                                                                 

        suffix = " #{counter += 1}"
        base = "#{base}#{suffix}"
        #space.update_attribute(:permalink,new_value)
        #Rails.logger.info "* Trying " + space.permalink                                                                                                                          
      end
      
      name = base
      permalink = s.permalink
      permalink = s.permalink + "-" + ActiveSupport::SecureRandom.random_number(9999).to_s if (s.permalink.length < 3)
      
      BigbluebuttonRoom.create!(:owner => s,
                                :server => BigbluebuttonServer.first,
                                :param => permalink,
                                :name => name)
                                
    end
  end

  def self.down
  end
end
