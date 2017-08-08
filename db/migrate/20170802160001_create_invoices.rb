class CreateInvoices < ActiveRecord::Migration
  def up
    create_table :invoices do |t|
      t.integer :subscription_id
      t.string :invoice_token
      t.string :invoice_url
      t.string :flag_invoice_status
      t.string :due_date
      t.integer :user_qty
    end
  end

  def down
    drop_table :invoices
  end
end
