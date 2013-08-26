class AddLogoImageToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :logo_image, :string
  end
end
