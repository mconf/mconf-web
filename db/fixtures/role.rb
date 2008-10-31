# db/fixtures/users.rb
# put as many seeds as you like in


Role.seed(:name) do |s|
   s.name= "Admin"
   s.create_entries= 1
   s.read_entries= 1
   s.update_entries= 1
   s.delete_entries= 1
   s.create_performances= 1
   s.read_performances= 1
   s.update_performances= 1
   s.delete_performances= 1
   s.manage_events= 1
   s.admin= 1
end

Role.seed(:name) do |s|
   s.name= "User"
   s.create_entries= 1
   s.read_entries= 1
   s.update_entries= 1
   s.delete_entries= 1
   s.create_performances= 0
   s.read_performances= 1
   s.update_performances= 0
   s.delete_performances= 0
   s.manage_events= 1
   s.admin= 1
end

Role.seed(:name) do |s|
   s.name= "Invited"
   s.create_entries= 0
   s.read_entries= 1
   s.update_entries= 0
   s.delete_entries= 0
   s.create_performances= 0
   s.read_performances= 1
   s.update_performances= 0
   s.delete_performances= 0
   s.manage_events= 0
   s.admin= 0
end