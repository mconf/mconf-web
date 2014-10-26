object @users => :users
attributes :id, :username, :name, :email
node(:text) { |user| html_escape("#{user.name} (#{user.username}, #{user.email})") }