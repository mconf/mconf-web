class CreateAttributeRoles < ActiveRecord::Migration
  def change
    create_table :attribute_roles do |t|
      t.string :oid
      t.integer :role_id
      t.timestamps
    end
  end
end
