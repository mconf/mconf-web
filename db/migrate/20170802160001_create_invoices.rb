class CreateInvoices < ActiveRecord::Migration
  def up
    create_table :invoices do |t|
      t.integer :subscription_id
      t.string :invoice_token
      t.string :invoice_url
      t.string :flag_invoice_status
      t.integer :user_qty
      t.datetime :due_date
    end
  end

  def down
    drop_table :invoices
  end
end
