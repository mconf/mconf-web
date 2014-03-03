object @users => :users
attributes :id, :username, :name, :email
node(:text) { |user| "#{user.name} (#{user.username}, #{user.email})" }