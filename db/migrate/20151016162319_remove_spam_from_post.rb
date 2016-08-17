class RemoveSpamFromPost < ActiveRecord::Migration
  def change
    remove_column :posts, :spam, :boolean
  end
end
