class AddShibPrincipalNameFieldToSites < ActiveRecord::Migration
  def change
    add_column :sites, :shib_principal_name_field, :string
  end
end
