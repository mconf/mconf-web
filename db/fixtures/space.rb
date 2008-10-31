# db/fixtures/space.rb
# put as many seeds as you like in

Space.seed(:name) do |s|
  s.name = "Public"
  s.public = true
  s.description = "Description of the public space"
  
end