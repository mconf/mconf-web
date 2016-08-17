class AddNewAccountToShibToken < ActiveRecord::Migration
  def up
    add_column :shib_tokens, :new_account, :boolean, default: false

    # Checks token.created_at - user.created_at < 10 seconds
    # Users created too long before the token means the user created it using another method
    # (local registration, ldap, etc).
    # Token created before the user means possibly an error when creating the user or old
    # base code. In this case we assume the user was created via shib.
    puts "Automatically setting tokens as :new_account if they match the default criteria"
    ShibToken.joins(:user)
      .where("TIMESTAMPDIFF(SECOND, users.created_at, shib_tokens.created_at) < 10")
      .find_each do |token|

      puts "* Setting 'new_account: true' on token ##{token.id} (#{token.identifier})"
      token.update_attribute(:new_account, true)
    end
  end

  def down
    remove_column :shib_tokens, :new_account
  end
end
