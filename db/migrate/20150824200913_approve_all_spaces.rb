class ApproveAllSpaces < ActiveRecord::Migration
  def change
    Space.update_all(approved: true)
  end
end
