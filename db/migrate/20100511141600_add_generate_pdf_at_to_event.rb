class AddGeneratePdfAtToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :generate_pdf_at, :datetime
  end

  def self.down
    remove_column :events, :generate_pdf_at
  end
end
