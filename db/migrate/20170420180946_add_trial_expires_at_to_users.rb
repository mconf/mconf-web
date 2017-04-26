class AddTrialExpiresAtToUsers < ActiveRecord::Migration
  def change
    add_column :users, :trial_expires_at, :datetime
  end
end
