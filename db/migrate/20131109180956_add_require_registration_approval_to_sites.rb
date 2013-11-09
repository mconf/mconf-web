class AddRequireRegistrationApprovalToSites < ActiveRecord::Migration
  def change
    add_column :sites, :require_registration_approval, :boolean, :default => false, :null => false
  end
end
