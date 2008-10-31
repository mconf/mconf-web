# db/fixtures/users.rb
# put as many seeds as you like in

User.seed(:login, :email) do |s|
  s.login = "admin" 
  s.email = "ebarra@dit.upm.es" 
  s.password = "prueba"
  s.password_confirmation = "prueba"
  s.superuser = true
end

User.seed(:login, :email) do |s|
  s.login = "rgmarin" 
  s.email = "rgmarin@dit.upm.es" 
  s.password = "prueba"
  s.password_confirmation = "prueba"
  s.superuser = false
  s.activated_at = "2008-04-03 17:34:59"
end