class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table "profiles", :force => true do |t|
      t.column :user_id,                  :integer, :null=>false
      t.column :name,                     :string
      t.column :lastname,                 :string
      t.column :organization,             :string
      t.column :phone,                    :string
      t.column :mobile,                   :string
      t.column :fax,                      :string
      t.column :address,                  :string
      t.column :city,                     :string
      t.column :zipcode,                  :string
      t.column :province,                 :string
      t.column :country,                  :string
    end
  end

  def self.down
    drop_table "profiles"
  end
end
