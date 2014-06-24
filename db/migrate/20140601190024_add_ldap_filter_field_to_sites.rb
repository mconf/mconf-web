class AddLdapFilterFieldToSites < ActiveRecord::Migration
  def change
    add_column :sites, :ldap_filter, :string
  end
end
