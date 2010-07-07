class AddGeneratePdfSmallAtToEvent < ActiveRecord::Migration
  def self.up
    add_column :events, :generate_pdf_small_at, :datetime
  end

  def self.down
    remove_column :events, :generate_pdf_small_at
  end
end
