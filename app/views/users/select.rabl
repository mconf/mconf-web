object @users => :users
attributes :id, :username, :name
attributes :email if can?(:manage, User)
node(:text) { |user| html_escape("#{user.name} (#{user.username}#{', ' + user.email if can?(:manage, User)})") }