class AddRequireSpaceApprovalAndForbidUserSpaceCreationToSites < ActiveRecord::Migration
  def change
    add_column :sites, :require_space_approval, :boolean, default: false
    add_column :sites, :forbid_user_space_creation, :boolean, default: false
  end
end
