class AddOidEeaToAttributeCertificateConfiguration < ActiveRecord::Migration
  def change
    add_column :attribute_certificate_configurations, :oid_eea, :string
  end
end
