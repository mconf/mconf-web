class DeniedAdmissions < ActiveRecord::Migration
  def self.up
    rename_column :admissions, :accepted_at, :processed_at
    add_column :admissions, :accepted, :boolean
  end

  def self.down
    rename_column :admissions, :processed_at, :accepted_at
    remove_column :admissions, :accepted
  end
end
