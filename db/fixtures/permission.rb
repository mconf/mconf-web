# db/fixtures/users.rb
# put as many seeds as you like in

Permission.seed(:action, :objective) do |p|
  p.action = "create"
  p.objective = "Content"
end

Permission.seed(:action, :objective) do |p|
  p.action = "read"
  p.objective = "Content"
end

Permission.seed(:action, :objective) do |p|
  p.action = "update"
  p.objective = "Content"
end

Permission.seed(:action, :objective) do |p|
  p.action = "delete"
  p.objective = "Content"
end

Permission.seed(:action, :objective) do |p|
  p.action = "read"
  p.objective = "Performance"
end
Permission.seed(:action, :objective) do |p|
  p.action = "create"
  p.objective = "Performance"
end
Permission.seed(:action, :objective) do |p|
  p.action = "update"
  p.objective = "Performance"
end
Permission.seed(:action, :objective) do |p|
  p.action = "delete"
  p.objective = "Performance"
end

