class CreatePlansAndSubscriptions < ActiveRecord::Migration
  def up
    create_table :plans do |t|
      t.string :name
      t.string :identifier
      t.string :ops_id
      t.string :ops_type
      t.string :currency
      t.string :interval_type
      t.integer :interval
      t.integer :item_price
      t.integer :base_price
      t.integer :max_users
    end

    create_table :subscriptions do |t|
      t.string :plan_id
      t.string :user_id
      t.string :customer_token
      t.string :subscription_token
      t.string :pay_day
      t.string :cpf_cnpj
      t.string :address
      t.string :additional_address_info
      t.string :number
      t.string :zipcode
      t.string :city
      t.string :province
      t.string :district
      t.string :country
    end
  end

  def down
    drop_table :plans
    drop_table :subscriptions
  end
end
