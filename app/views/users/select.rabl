object @users => :users
attributes :id, :username, :name
node(:text) { |user| "#{user.name} (#{user.username})" }