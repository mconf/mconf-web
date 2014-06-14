class RemoveSpaceParentId < ActiveRecord::Migration
  def up
    remove_column :spaces, :parent_id
  end

  def down
    add_column :spaces, :parent_id, :integer
  end
end
