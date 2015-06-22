class AddApprovedToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :approved, :boolean, default: true
  end
end
