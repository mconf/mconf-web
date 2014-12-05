class AddSecretTokenForEveryJoinRequest < ActiveRecord::Migration
  def up
    connection = ActiveRecord::Base.connection()
    ids = connection.execute("SELECT id from `join_requests`;").to_a

    ids.each do |id|
      tok = SecureRandom.urlsafe_base64(16)
      connection.execute("UPDATE join_requests SET secret_token = '#{tok}' WHERE id = '#{id.first}'")
    end
  end

  def down
  end
end
