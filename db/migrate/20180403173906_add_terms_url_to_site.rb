class AddTermsUrlToSite < ActiveRecord::Migration
  def change
    add_column :sites, :terms_url, :string
  end
end
