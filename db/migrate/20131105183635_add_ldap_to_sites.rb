class AddLdapToSites < ActiveRecord::Migration
  def change
    add_column :sites, :ldap_enabled, :boolean
    add_column :sites, :ldap_host, :string
    add_column :sites, :ldap_port, :integer
    add_column :sites, :ldap_user, :string
    add_column :sites, :ldap_user_password, :string
    add_column :sites, :ldap_user_treebase, :string
    add_column :sites, :ldap_username_field, :string
    add_column :sites, :ldap_email_field, :string
    add_column :sites, :ldap_name_field, :string
  end
end
