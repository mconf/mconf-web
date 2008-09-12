    atom_feed do |feed|
      feed.title("Users")
      feed.updated((@users.first.created_at))

      for user in @users
        feed.entry(user) do |entry|
          entry.title(user.name)
          entry.login(user.login)
          entry.activated_at(user.activated_at)
          entry.activation_code(user.activation_code)
          entry.created_at(user.created_at)
          entry.crypted_password(user.crypted_password)
          entry.disabled(user.disabled)
          entry.email(user.email)
          entry.email2(user.email2)
          entry.email3(user.email3)
          entry.id(user.id)
          entry.remember_token(user.remember_token)
          entry.remember_token_expires_at(user.remember_token_expires_at)
          entry.reset_password_code(user.reset_password_code)
          entry.salt(user.salt)
          entry.superuser(user.superuser)
          entry.updated_at(user.updated_at)
          
          

          entry.author do |author|
            author.name("SIR")
          end
        end
      end
    end
