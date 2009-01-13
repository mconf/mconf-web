# db/fixtures/users.rb
# put as many seeds as you like in


admin_role = Role.seed(:name) do |r|
   r.name= "Admin"
   r.stage_type = "Space"
end
admin_role.permissions << Permission.find_by_action_and_objective('read',   'self')
admin_role.permissions << Permission.find_by_action_and_objective('update', 'self')
admin_role.permissions << Permission.find_by_action_and_objective('delete', 'self')
admin_role.permissions << Permission.find_by_action_and_objective('create', 'Content')
admin_role.permissions << Permission.find_by_action_and_objective('read',   'Content')
admin_role.permissions << Permission.find_by_action_and_objective('update', 'Content')
admin_role.permissions << Permission.find_by_action_and_objective('delete', 'Content')
admin_role.permissions << Permission.find_by_action_and_objective('create', 'Performance')
admin_role.permissions << Permission.find_by_action_and_objective('read',   'Performance')
admin_role.permissions << Permission.find_by_action_and_objective('update', 'Performance')
admin_role.permissions << Permission.find_by_action_and_objective('delete', 'Performance')

user_role = Role.seed(:name) do |r|
   r.name= "User"
   r.stage_type = "Space"
end
user_role.permissions << Permission.find_by_action_and_objective('read',   'self')
user_role.permissions << Permission.find_by_action_and_objective('create', 'Content')
user_role.permissions << Permission.find_by_action_and_objective('read',   'Content')
user_role.permissions << Permission.find_by_action_and_objective('create', 'Performance')
user_role.permissions << Permission.find_by_action_and_objective('read',   'Performance')

invited_role = Role.seed(:name) do |r|
   r.name= "Invited"
   r.stage_type = "Space"
end
invited_role.permissions << Permission.find_by_action_and_objective('read', 'self')
invited_role.permissions << Permission.find_by_action_and_objective('read', 'Content')
invited_role.permissions << Permission.find_by_action_and_objective('read', 'Performance')

reader_role = Role.seed(:name) do |r|
  r.name = "Reader"
  r.stage_type = ""
end
reader_role.permissions << Permission.find_by_action_and_objective('read', 'self')
