# db/fixtures/space.rb
# put as many seeds as you like in

public_space = Space.seed(:name) do |s|
  s.name = "Public"
  s.description = "Description of the public space"
end

public_space.stage_performances.create(:role => Role.find_by_name_and_stage_type("Invited", "Space"), 
                                       :agent => Anyone.current)

