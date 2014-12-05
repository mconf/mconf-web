class AddSecretTokenToJoinRequest < ActiveRecord::Migration
  def change
    add_column :join_requests, :secret_token, :string
  end
end
