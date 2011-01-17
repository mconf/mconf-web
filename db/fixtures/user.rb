# db/fixtures/users.rb
# put as many seeds as you like in

User.all.map(&:destroy)

User.seed(:login, :email) do |s|
  s.login = "admin" 
  s.email = "mconf.prav@gmail.com"
  s.password = "discovoador"
  s.password_confirmation = "discovoador"
  s.superuser = true
  s.activated_at = "2010-04-03 17:34:59"
  s.activation_code = nil
end

User.seed(:login, :email) do |s|
  s.login = "daileon" 
  s.email = "daileon@inf.ufrgs.br" 
  s.password = "discovoador"
  s.password_confirmation = "discovoador"
  s.superuser = false
  s.activated_at = "2010-04-03 17:34:59"
  s.activation_code = nil
end
