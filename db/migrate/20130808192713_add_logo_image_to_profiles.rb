class AddLogoImageToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :logo_image, :string
  end
end
