xml.instruct!
if @user
  xml.user do
    xml.name @user.name
    xml.username @user.login
  end
else
  xml.user
end