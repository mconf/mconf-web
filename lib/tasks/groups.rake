namespace :groups do
  desc "Upadte all application groups to create the associated group mailing lists"
  task(:update_groups => :environment) {
    Space.find(:all).each do |space|
     space.groups.each do |group|
       group.save
     end
   end
  }
end

