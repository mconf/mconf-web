class ChangeIsGroupToType < ActiveRecord::Migration
  def self.up
    add_column "cms_roles", :type, :string
    remove_column "cms_roles", "is_group"
  end

  def self.down
    remove_column "cms_roles", :type
    add_column "cms_roles", "is_group", :boolean
  end
end
