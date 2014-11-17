class AddSecretTokenForEveryJoinRequest < ActiveRecord::Migration
  def up
    JoinRequest.all.map(&:save)
  end

  def down
  end
end
