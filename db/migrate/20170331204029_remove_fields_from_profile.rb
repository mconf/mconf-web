class RemoveFieldsFromProfile < ActiveRecord::Migration
  def up
    Profile.find_each do |profile|
      if profile.phone.blank? && !profile.mobile.blank?
        profile.update_attributes(phone: profile.mobile)
      end
    end

    remove_column :profiles, :prefix_key
    remove_column :profiles, :mobile
    remove_column :profiles, :fax
    remove_column :profiles, :skype
    remove_column :profiles, :im
    remove_column :profiles, :visibility
  end

  def down
    add_column :profiles, :prefix_key, :string
    add_column :profiles, :mobile, :string
    add_column :profiles, :fax, :string
    add_column :profiles, :skype, :string
    add_column :profiles, :im, :string
    add_column :profiles, :visibility, :integer, default: 3
  end
end
