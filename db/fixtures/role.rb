# db/fixtures/users.rb
# put as many seeds as you like in


admin_role = Role.seed(:name) do |r|
   r.name= "Admin"
   r.stage_type = "Space"
end
admin_role.permissions << Permission.find_by_array([ :create, :Content ])
admin_role.permissions << Permission.find_by_array([ :read, :Content ])
admin_role.permissions << Permission.find_by_array([ :update, :Content ])
admin_role.permissions << Permission.find_by_array([ :delete, :Content ])
admin_role.permissions << Permission.find_by_array([ :create, :Performance ])
admin_role.permissions << Permission.find_by_array([ :read, :Performance ])
admin_role.permissions << Permission.find_by_array([ :update, :Performance ])
admin_role.permissions << Permission.find_by_array([ :delete, :Performance ])

user_role = Role.seed(:name) do |r|
   r.name= "User"
   r.stage_type = "Space"
end
user_role.permissions << Permission.find_by_array([ :create, :Content ])
user_role.permissions << Permission.find_by_array([ :read, :Content ])
user_role.permissions << Permission.find_by_array([ :update, :Content ])
user_role.permissions << Permission.find_by_array([ :delete, :Content ])
user_role.permissions << Permission.find_by_array([ :read, :Performance ])

invited_role = Role.seed(:name) do |r|
   r.name= "Invited"
   r.stage_type = "Space"
end
user_role.permissions << Permission.find_by_array([ :read, :Content ])
user_role.permissions << Permission.find_by_array([ :read, :Performance ])
