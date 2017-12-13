class AddDefaultFalseToInvoiceNotified < ActiveRecord::Migration
  def change
    change_column_default :invoices, :notified, false
  end
end
