class CreateParticipantConfirmations < ActiveRecord::Migration
  def change
    create_table(:participant_confirmations) do |t|
      ## Confirmable
      t.string   :token
      t.integer  :participant_id
      t.string   :confirmed_at
      t.timestamps
    end
  end
end
