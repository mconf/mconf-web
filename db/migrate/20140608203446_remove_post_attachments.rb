class RemovePostAttachments < ActiveRecord::Migration
  def up
    drop_table :post_attachments
  end

  def down
    throw ActiveRecord::IrreversibleMigration
  end
end
