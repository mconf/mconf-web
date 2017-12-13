class AddNotifiedToInvoice < ActiveRecord::Migration
  def change
	 add_column :invoices, :notified, :boolean
  end
end
